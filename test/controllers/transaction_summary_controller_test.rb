# frozen_string_literal: true

require "test_helper"

class TransactionSummaryControllerTest < ActionDispatch::IntegrationTest
  include RegimeSetup

  def test_it_should_get_index_for_xhr
    setup_cfd
    get regime_transaction_summary_index_url(@regime), xhr: true
    assert_response :success
  end

  def test_read_only_user_should_not_get_index_for_xhr
    setup_cfd_read_only
    get regime_transaction_summary_index_url(@regime), xhr: true
    assert_redirected_to root_path
  end
end
