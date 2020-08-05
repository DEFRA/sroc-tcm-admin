require 'test_helper.rb'
require 'webmock/minitest'

class APIConnectorServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    # Disable network connections to enforce API mocking
    WebMock.disable_net_connect!
    @api_url ||= URI.parse("#{ENV.fetch('CHARGING_MODULE_API')}/test")
    @cognito_url ||= URI.parse("#{ENV.fetch('COGNITO_HOST')}/oauth2/token")
    stub_request(:post, @cognito_url).to_return(valid_auth_response)
  end

  def teardown
    # Re-enable network connections
    WebMock.allow_net_connect!
  end

  def test_can_get
    stub_request(:get, @api_url).to_return(body: test_ok)
    api_object = APIConnector::APIObject.new

    response = api_object.get('test')

    assert(response.success?)
    assert_equal(response.body, test_ok_symbolized)
  end

  def test_can_post
    stub_request(:post, @api_url).to_return(body: test_ok)
    api_object = APIConnector::APIObject.new

    response = api_object.post('test', test: 'test')

    assert(response.success?)
    assert_equal(response.body, test_ok_symbolized)
  end

  def test_api_server_500_error
    stub_request(:get, @api_url).to_return(status: 500)
    api_object = APIConnector::APIObject.new

    TcmLogger.expects(:error).once
    response = api_object.get('test')

    assert_equal(response.success?, false)
  end

  def test_api_server_400_error
    stub_request(:get, @api_url).to_return(status: 400)
    api_object = APIConnector::APIObject.new

    TcmLogger.expects(:notify).once
    response = api_object.get('test')

    assert_equal(response.success?, false)
  end

  def test_api_unexpected_error
    stub_request(:get, @api_url).to_timeout
    api_object = APIConnector::APIObject.new

    TcmLogger.expects(:notify).once
    response = api_object.get('test')

    assert_equal(response.success?, false)
  end

  def test_ok
    '{"test": "ok"}'
  end

  def test_ok_symbolized
    JSON.parse(test_ok, symbolize_names: true)
  end

  def valid_auth_response
    {
      headers: { 'Content-Type' => 'application/json' },
      status: 200,
      body:
        %({
          "access_token": "dummy_auth_token",
          "expires_in": 3600,
          "token_type": "Bearer"
        })
    }
  end
end
