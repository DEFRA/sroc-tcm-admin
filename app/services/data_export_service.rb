# frozen_string_literal: true

class DataExportService < ServiceObject
  def initialize(params = {})
    super()
    @regimes = regimes(params.fetch(:regime, nil))
  end

  def call
    @result = false
    begin
      puts("Started transaction data export")
      @regimes.each do |regime|
        puts("Processing regime #{regime.name}")
        result = ExportTransactionDataService.call(regime: regime)
        if result.failed?
          TcmLogger.error("Failed to export transactions for #{regime.name}")
        else
          # store file
          result = PutDataExportFileService.call(filename: result.filename)
          TcmLogger.error("Failed to store export data file for #{regime.name}") if result.failed?
        end
      end
      @result = true
    rescue StandardError => e
      TcmLogger.notify(e)
    ensure
      puts("Finished transaction data export")
    end
    self
  end
end

private

def regimes(regime)
  return [regime] if regime

  Regime.all
end
