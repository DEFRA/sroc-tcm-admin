require 'test_helper.rb'

class HistoryControllerTest < ActionDispatch::IntegrationTest
  def setup
    @regime = regimes(:cfd)
  end

  def test_it_should_get_index
    get regime_history_index_url(@regime)
    assert_response :success
  end

  def test_it_should_get_index_for_json
    get regime_history_index_url(@regime, format: :json)
    assert_response :success
  end
end

