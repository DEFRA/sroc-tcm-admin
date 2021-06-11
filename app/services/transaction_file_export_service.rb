# frozen_string_literal: true

class TransactionFileExportService < ServiceObject
  def initialize
    super()
  end

  def call
    @result = false
    begin
      puts("Started transaction file export")

      TransactionFile.where(state: 'initialised').each do |transaction_file|
        exporter = TransactionFileExporter.new(
          transaction_file.regime,
          transaction_file.region,
          transaction_file.user
        )
        exporter.generate_output_file(transaction_file)
        puts("Exported transaction file #{transaction_file.file_reference}")
      end
      @result = true
    rescue StandardError => e
      TcmLogger.notify(e)
    ensure
      puts("Finished transaction file export")
    end
    self
  end
end
