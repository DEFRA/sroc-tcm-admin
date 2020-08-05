module APIConnector
  class AuthorisationObject < ServiceObject
    attr_reader :token

    def initialize(_params = {})
      @username = ENV['COGNITO_USERNAME']
      @password = ENV['COGNITO_PASSWORD']
      @host = ENV['COGNITO_HOST']
      @token_url = '/oauth2/token'
    end

    def call
      @token = client.client_credentials.get_token.token
    rescue StandardError => e
      @result = false
      raise Exceptions::APIConnectorError, "Error retrieving Congito token: #{e}"
    else
      @result = true
      self
    end

    def client
      OAuth2::Client.new(@username, @password, site: @host, token_url: @token_url)
    end
  end
end
