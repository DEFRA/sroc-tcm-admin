# frozen_string_literal: true

class DataExportService < ServiceObject
  attr_reader :results

  def initialize(params = {})
    super()
    @regimes = regimes(params.fetch(:regime, nil))

    @results = {
      succeeded: [],
      failed: []
    }
  end

  def call
    @result = false
    begin
      puts("Started transaction data export")
      @regimes.each do |regime|
        puts("Processing regime #{regime.name}")
        result = ExportTransactionDataService.call(regime: regime)
        if result.failed?
          record_failure(result, "Failed to export transactions for #{regime.name}")
        else
          # store file
          result = PutDataExportFileService.call(filename: result.filename)
          if result.failed?
            record_failure(result, "Failed to store export data file for #{regime.name}")
          else
            record_success(result)
          end
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

def record_failure(result, message)
  TcmLogger.error(message)
  @results[:failed].push(filename_only(result.filename))
end

def record_success(result)
  @results[:succeeded].push(filename_only(result.filename))
end

def filename_only(filename)
  return "" unless filename

  File.basename(filename)
end
