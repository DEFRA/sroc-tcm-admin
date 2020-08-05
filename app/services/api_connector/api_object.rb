require 'net/http'

module APIConnector
  class APIObject < ServiceObject
    attr_reader :body

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
      handle_response(endpoint, http, response)
      self
    rescue StandardError => e
      tcm_api_other_error(e)
      self
    end

    def handle_response(endpoint, http, response)
      case response
      when Net::HTTPSuccess
        build_success_response(response)
      when Net::HTTPInternalServerError
        tcm_api_error(endpoint, http, response)
      else
        api_connector_error(endpoint, http, response)
      end
    end

    def tcm_api_error(endpoint, http, response)
      # Charging module API server error
      TcmLogger.error("Bill run service problem: #{http} #{endpoint} #{response.body}")
      build_error_response('Unable to retrieve data due to an unexpected error in the Charging Module API.'\
        '\nPlease try again later')
    end

    def api_connector_error(endpoint, http, response)
      # something unexpected happened
      TcmLogger.notify(Exceptions::APIConnectorError.new("#{http} #{endpoint} #{response.body}"))
      build_error_response('Unable to retrieve data due to an unexpected error.'\
        '\nPlease try again later')
    end

    def tcm_api_other_error(error)
      # something REALLY unexpected happened ...
      TcmLogger.notify(error)
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

    def build_success_response(response)
      @result = true
      @body = JSON.parse(response.body, symbolize_names: true)
    end

    def build_error_response(text)
      @result = false
      @body = text
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
      @auth_token ||= APIConnector::AuthorisationObject.call.token
    end
  end
end
