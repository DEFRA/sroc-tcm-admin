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

  def do_not_touch_tables
    @do_not_touch_tables ||= %w[
      ar_internal_metadata
      exclusion_reasons
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
