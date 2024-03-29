# frozen_string_literal: true

class CleanDbService < ServiceObject
  attr_reader :results

  def initialize(_params = {})
    super()

    @results = { succeeded: [] }
  end

  def call
    clean_tables
    reset_counters
    reset_exported_data_files
    @result = true

    self
  rescue StandardError => e
    @result = false
    Rails.logger.error("Could not clean the db: #{e.message}")

    self
  end

  private

  def clean_tables
    ActiveRecord::Base.connection.tables.each do |table|
      next if do_not_touch_tables.include?(table)

      ActiveRecord::Base.connection.execute("TRUNCATE #{table} CASCADE")
      @results[:succeeded].push(table)
    end
  end

  def reset_counters
    ActiveRecord::Base.connection.execute("UPDATE sequence_counters SET file_number=50001, invoice_number=1")
  end

  def reset_exported_data_files
    ActiveRecord::Base.connection.execute(
      "UPDATE export_data_files SET"\
      " last_exported_at = NULL,"\
      " status = 0,"\
      " exported_filename = NULL,"\
      " exported_filename_hash = NULL"
    )
  end

  def do_not_touch_tables
    @do_not_touch_tables ||= %w[
      annual_billing_data_files
      ar_internal_metadata
      data_upload_errors
      exclusion_reasons
      export_data_files
      permit_categories
      regime_users
      regimes
      schema_migrations
      sequence_counters
      sequence_counters
      users
    ]
  end
end
