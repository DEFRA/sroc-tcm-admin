# frozen_string_literal: true

require "net/http"

class RulesService  < ServiceObject
  def initialize(params = {})
    super()
    @params = params
  end

  def call
    regime = @params.fetch(:regime)
    financial_year = @params.fetch(:financial_year)
    payload = @params.fetch(:payload)

    path = determine_path(regime.slug, financial_year)
    @url = build_url(path)
    request = build_request(payload)
    response = connection.request(request)

    case response
    when Net::HTTPSuccess
      # successfully completed charge calculation or
      # an error in the calculation or a ruleset issue
      # we want to show an error at the front end if there's an issue
      JSON.parse(response.body)
    when Net::HTTPInternalServerError
      TcmLogger.error("Calculate charge problem: #{JSON.parse(response.body)}")
      # some kind of server error at the charging service
      error_response("Unable to calculate charge due to an unexpected error "\
                     "at the Charge Service.\nPlease try again later")
    else
      # something unexpected happened
      TcmLogger.notify(Exceptions::CalculationServiceError.new(response.value))
      error_response("Unable to calculate charge due to an unexpected error."\
                     "\nPlease try again later")
    end
  rescue StandardError => e
    # something REALLY unexpected happened ...
    TcmLogger.notify(e)
    error_response("Unable to calculate charge due to the rules service "\
                   "being unavailable. Please log a call with the "\
                   "service desk.")
  end

  def self.test_payload(regime)
    {
      tcmChargingRequest: {
        permitCategoryRef: regime.permit_categories.first.code,
        percentageAdjustment: "100",
        temporaryCessation: false,
        compliancePerformanceBand: "B",
        billableDays: 365,
        financialDays: 365,
        chargePeriod: "FY1819",
        preConstruction: false,
        environmentFlag: "TEST"
      }
    }
  end

  private

  def determine_path(regime, financial_year)
    env_slug = regime.upcase.squish
    year_suffix = "_#{financial_year}_#{(financial_year + 1).to_s[-2..3]}"

    path = File.join(ENV.fetch("#{env_slug}_APP"), ENV.fetch("#{env_slug}_RULESET"))

    return "#{path}#{year_suffix}"
  end

  def build_url(path)
    URI.parse(File.join(ENV.fetch("RULES_SERVICE_URL"), path))
  end

  def connection
    http = Net::HTTP.new(@url.host, @url.port)
    http.use_ssl = @url.scheme.downcase == "https"

    http
  end

  def build_request(payload)
    request = Net::HTTP::Post.new(@url.request_uri, 'Content-Type': "application/json")
    request.body = payload.to_json
    request.basic_auth(ENV.fetch("RULES_SERVICE_USER"), ENV.fetch("RULES_SERVICE_PASSWORD"))

    request
  end

  def error_response(text)
    { "calculation": { "messages": text } }
  end
end
