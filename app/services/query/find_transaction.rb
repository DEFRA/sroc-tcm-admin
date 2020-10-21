# frozen_string_literal: true

module Query
  class FindTransaction < QueryObject
    def initialize(opts = {})
      super()
      @regime = opts.fetch(:regime)
      @transaction_id = opts.fetch(:transaction_id)
    end

    def call
      # NOTE: doesn't return a query
      @regime.transaction_details.find(@transaction_id)
    end
  end
end
