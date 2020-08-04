module APIConnector
  class CreateBillRun < APIObject
    def initialize(params = {})
      @regime = params.fetch(:regime)
      @region = params.fetch(:region)
      @endpoint = "#{@regime}/billruns"
    end

    def call
      post(@endpoint, region: @region)
    end
  end
end
