# frozen_string_literal: true

source "https://rubygems.org"
ruby "2.7.1"

gem "rails", "~> 7.0"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5"

gem "airbrake", "~> 13.0"
gem "aws-sdk", "~> 2"
# bootstrap 4
gem "bootstrap", "~> 4.3.1"
gem "bstard"
gem "devise"
gem "devise_invitable"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.11"
# jquery needed by bootstrap for rails 5.1+
gem "jquery-rails"
gem "jquery-ui-rails"
gem "kaminari"
# GOV.UK Notify gem. Allows us to send email via the Notify web API
gem "notifications-ruby-client"
# Default web server for rails. For those coming from Rails 4 this replaces webrick in development. For those working
# on other Defra services this replaces passenger.
gem "puma"
gem "rails-i18n"
gem "rails_semantic_logger"
# Use SCSS for stylesheets
gem "sass-rails", "~> 5.1"
gem "secure_headers"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", "~> 4.2"
gem "whenever", require: false

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5.2"

group :development do
  # Manages our rubocop style rules for all defra ruby projects
  gem "defra_ruby_style"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "web-console"
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug"
  # Shim to load environment variables from a .env file into ENV in development
  # and test
  gem "dotenv-rails"
  # Project uses RSpec as its test framework
  gem "rspec-rails"
end

group :test do
  gem "capybara"
  gem "capybara-selenium"
  # Needed because the existing minitest suite leaves data in the DB which interferes with the rspec tests
  gem "database_cleaner-active_record"
  gem "factory_bot_rails"
  gem "mocha"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  # Generates a test coverage report on every `bundle exec rspec` call. We use
  # the output to feed SonarCloud's stats and analysis. It does not yet support
  # v0.18 hence locked to 0.17
  gem "simplecov", "~> 0.17.1", require: false
  # Stubbing HTTP requests
  gem "webmock"
end

group :production do
  # Use passenger as the app server in production. The environment web-ops have
  # built currently expects this to be the case
  gem "passenger", "~> 5.1", require: false
end
