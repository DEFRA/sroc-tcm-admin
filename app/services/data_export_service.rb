# frozen_string_literal: true

class DataExportService < ServiceObject
  def initialize(_params = {})
    super()
  end

  def call
    @result = false
    ActiveRecord::Base.connection_pool.with_connection do
      Regime.all.each do |regime|
        result = ExportTransactionData.call(regime: regime, batch_size: 1000)
        if result.failed?
          TcmLogger.error("Failed to export transactions for #{regime.name}")
        else
          # store file
          result = PutDataExportFile.call(filename: result.filename)
          TcmLogger.error("Failed to store export data file for #{regime.name}") if result.failed?
        end
      end
    end
    @result = true
  rescue StandardError => e
    TcmLogger.notify(e)
  end
end
