require 'net/http'
require 'Base64'

module APIConnector
  class APIObject < ServiceObject
    def get(endpoint, payload = '')
      api_request(endpoint, payload, Net::HTTP::Get)
    end

    def post(endpoint, payload = '')
      api_request(endpoint, payload, Net::HTTP::Post)
    end

    def patch(endpoint, payload = '')
      api_request(endpoint, payload, Net::HTTP::Patch)
    end

    def delete(endpoint, payload = '')
      api_request(endpoint, payload, Net::HTTP::Delete)
    end

    private

    def api_request(endpoint, payload, http)
      request = build_http_request(endpoint, payload, http)
      response = http_connection.request(request)

      case response
      when Net::HTTPSuccess
        return { success: true, body: JSON.parse(response.body, symbolize_names: true )}
      when Net::HTTPInternalServerError
        # Charging module API server error
        TcmLogger.error("Bill run service problem: #{http} #{endpoint} #{response.body}")
        build_error_response('Unable to retrieve data due to an unexpected error in the Charging Module API.'\
          '\nPlease try again later')
      else
        # something unexpected happened
        TcmLogger.notify(Exceptions::APIConnectorError.new("#{http} #{endpoint} #{response.body}"))
        build_error_response('Unable to retrieve data due to an unexpected error.'\
          '\nPlease try again later')
      end
    rescue => e
      # something REALLY unexpected happened ...
      TcmLogger.notify(e)
      build_error_response('Unable to retrieve data from the Charging Module API. '\
        'Please log a call with the service desk.')
    end

    def build_http_request(endpoint, payload, http)
      request = http.new(
        "#{api_url}/#{endpoint}",
        'Content-Type': 'application/json',
        'Authorization': auth_token
      )
      request.body = payload.to_json
      request
    end

    def build_error_response(text)
      { success: false, body: text }
    end

    def api_url
      URI.parse(ENV['CHARGING_MODULE_API'])
    end

    def http_connection
      http = Net::HTTP.new(api_url.host, api_url.port)
      http.use_ssl = api_url.scheme.downcase == 'https'
      http
    end

    def auth_token
      @auth_token ||= make_token_request.token
    end

    def make_token_request
      client  = OAuth2::Client.new(
        ENV['COGNITO_USERNAME'], ENV['COGNITO_PASSWORD'],
        site: ENV['COGNITO_HOST'], token_url: '/oauth2/token'
      )
      begin
        token = client.client_credentials.get_token
      rescue => e
        raise Exceptions::APIConnectorError.new("Error retrieving Congito token: #{e}")
      else
        token
      end
    end
  end
end
