# frozen_string_literal: true

require "csv"
require "digest"
require "fileutils"

class ExportTransactionDataService < ServiceObject
  include RegimePresenter

  attr_reader :regime, :batch_size

  def initialize(params = {})
    super()
    @regime = params.fetch(:regime)
    @batch_size = params.fetch(:batch_size, 1000)
  end

  def call
    # export all transactions to csv for the given regime batch results
    edf = regime.export_data_file
    edf.generating!
    begin
      ExportDataFile.transaction do
        CSV.open(filename, "w", write_headers: true, headers: regime_headers) do |csv|
          export_transactions(csv)
        end
      end
      package_file(edf.compress?)

      sha1 = generate_file_hash(filename)

      edf.update!(last_exported_at: Time.zone.now,
                  exported_filename: File.basename(filename),
                  exported_filename_hash: sha1)
      edf.success!
      @result = true
    rescue StandardError => e
      TcmLogger.notify(e)
      edf.failed!
      @result = false
    end
    self
  end

  def filename
    @filename ||= File.join(cache_path, regime.export_data_file.filename).to_s
  end

  private

  def transactions
    regime
      .transaction_details
      .includes(:suggested_category,
                :transaction_header,
                :transaction_file)
      .order(:region)
      .order(:transaction_date)
      .order(:id)
  end

  def export_transactions(csv)
    # We need to be mindful that this is all transaction records for the regime and will grow so we need to batch query
    # or we will quickly run out of memory on the server. However, ActiveRecord#find_each ignores any order clause (it
    # uses :id only) so we are rolling our own here
    query = transactions
    count = query.count
    offset = 0
    while offset < count
      query.offset(offset).limit(@batch_size).each do |transaction|
        t = presenter.new(transaction)
        csv << regime_columns.map { |c| t.send(c) }
      end
      offset += batch_size
    end
  end

  def package_file(compress)
    @filename = compress_file(filename) if compress
  rescue StandardError => e
    TcmLogger.notify(e)
  end

  def compress_file(file_to_compress)
    # Force compression and suppress all warnings whilst you do it
    `gzip -fq #{file_to_compress}`
    "#{file_to_compress}.gz"
  end

  def generate_file_hash(file)
    Digest::SHA1.file(file).hexdigest
  end

  def regime_headers
    ExportFileFormat::EXPORT_COLUMNS.map { |c| c[:heading] }
  end

  def regime_columns
    ExportFileFormat::EXPORT_COLUMNS.map { |c| c[:accessor] }
  end

  def cache_path
    path = Rails.root.join("tmp", "cache", "export_data")
    FileUtils.mkdir_p path unless Dir.exist? path
    path
  end
end
