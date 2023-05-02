# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# See comment 'Add custom delivery method for emails' below
require_relative "../app/lib/notify_mail"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SrocTcmAdmin
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.i18n.available_locales = ["en-GB", :en]
    config.i18n.default_locale = :'en-GB'
    config.i18n.fallbacks = [:en]

    # Don't generate system test files.
    config.generators.system_tests = nil

    # exception handling
    config.exceptions_app = routes

    # Add custom delivery method for emails
    #
    # Rails and ActionMailer all default to expecting to send emails via SMTP. This is what you get after running
    # `rails new`. But most email providers, for example Sendgrid, now provide web API's for sending email. This is also
    # the only way to interact with GOV.UK Notify. It is also common to find a Postfix server instance in environments
    # using SMTP. This is because cloud providers like AWS have tools built in for monitoring HTTP traffic. But for SMTP
    # traffic you'll need to manually setup something like Postfix.
    #
    # So, to avoid the complexity of needing to maintain a Postifx instance and to allow us to use GOV.UK Notify for
    # emails the TCM adds its own custom delivery method in `app/lib/notify_mail.rb`.
    #
    # We used the following examples and references as a basis for this implementation
    #
    # - https://stackoverflow.com/a/64447545/6117745
    # - https://github.com/platanus/send_grid_mailer
    # - https://github.com/jorgemanrubia/mailgun_rails
    # - https://stackoverflow.com/q/5679571/6117745
    # - https://stackoverflow.com/a/37444960/6117745
    #
    # By building on ActionMailer and adding a custom delivery option we can still allow Rails and Devise to operate
    # as normal. The Rails ActionMailer config options still work, for example, `raise_delivery_errors` will squash or
    # throw errors depending on your setting. Our /last-email functionality also still works because `NotifyMail` is
    # still compatible with registered observers
    #
    # The one issue we hit was ensuring `NotifyMail` had been required before we attempted to add it as a delivery
    # method. The examples either used a `config/initializers` or added the call to the bottom of the file where the
    # class was declared.
    #
    # In our case neither were called before the `config.action_mailer.delivery_method = :notify_mail` call in
    # `config/environments/development.rb` and `production.rb`. This resulted in an error and the app refusing to load.
    # Adding the require and `add_delivery_method()` call here ensured it was definately known and stopped the error.
    ActionMailer::Base.add_delivery_method(:notify_mail, NotifyMail)
  end
end
