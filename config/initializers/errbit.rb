# frozen_string_literal: true

if defined?(Airbrake)
  Airbrake.configure do |config|
    config.host = ENV.fetch("AIRBRAKE_HOST")
    config.project_id = 1
    config.project_key = ENV.fetch("AIRBRAKE_KEY")
  end
end
