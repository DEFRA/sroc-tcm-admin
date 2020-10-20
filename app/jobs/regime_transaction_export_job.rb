# frozen_string_literal: true

class RegimeTransactionExportJob < ApplicationJob
  queue_as :default

  def perform(regime_id)
    ActiveRecord::Base.connection_pool.with_connection do
      regime = Regime.find(regime_id)
      result = ExportTransactionData.call(regime: regime,
                                          batch_size: 1000)
      if result.failed?
        TcmLogger.error("Failed to export transactions for #{regime.name}")
      else
        # store file
        result = PutDataExportFile.call(filename: result.filename)
        TcmLogger.error("Failed to store export data file for #{regime.name}") if result.failed?
      end
    end
  rescue => e
    TcmLogger.notify(e)
  end
end
