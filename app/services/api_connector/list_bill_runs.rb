module APIConnector
  class ListBillRuns < APIObject
    def initialize(params = {})
      regime = params.fetch(:regime)
      @endpoint = "#{regime}/billruns"
    end

    def call
      get(@endpoint)
    end
  end
end
