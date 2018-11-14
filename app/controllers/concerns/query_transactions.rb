module QueryTransactions
  extend ActiveSupport::Concern

  def query_params
    # region = params.fetch(:region, cookies.fetch(:region, ''))
    # region = '' if region == 'all'
    {
      regime: @regime,
      region: @region,
      financial_year: @financial_year,
      search: params.fetch(:search, cookies.fetch(:search, '')),
      sort: params.fetch(:sort, cookies.fetch(:sort, 'customer_reference')),
      sort_direction: params.fetch(:sort_direction,
                                   cookies.fetch(:sort_direction, 'asc'))
    }
  end
end
