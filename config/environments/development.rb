# frozen_string_literal: true

Rails.application.configure do
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Sending e-mails is required for user account management. We send invitation, reset password and unlock account
  # emails to users.
  config.action_mailer.default_url_options = {
    host: ENV.fetch("DEFAULT_URL_HOST", "http://localhost:3000"),
    protocol: "http"
  }

  # Don't care if the mailer can't send (if set to false)
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :notify_mail
  config.action_mailer.notify_mail_settings = { api_key: ENV["NOTIFY_API_KEY"] }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  config.i18n.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  #
  # NOTE: The default for this is ActiveSupport::EventedFileUpdateChecker and it worked fine when we first moved to
  # Docker. But as of June 30 2023 it now causes an error when launching in development mode and during our Docker
  # build when compiling the assets. The one clue we found was this
  #
  # https://dev.to/chrsgrrtt/rails-views-not-updating-locally-191o
  #
  # The writer identified the source as this line in the config being set to EventedFileUpdateChecker. They suggest
  # it dislikes either Docker volumes or Windows. We already know FS events don't behave the same in Docker as when
  # working locally so it's most likely true. But whilst they suggest commenting it out (also suggested in this
  # issue https://github.com/rails/rails/issues/36158) a commenter to the post suggests switching it for
  # FileUpdateChecker. Like others, this worked for us and means file watching is still enabled.
  config.file_watcher = ActiveSupport::FileUpdateChecker

  # The rails web console allows you to execute arbitrary code on the server. By
  # default, only requests coming from IPv4 and IPv6 localhosts are allowed.
  # When not running on directly on the host, for example in a Docker container
  # it'll use a different IP which causes `Cannot render console from 10.0.2.2!`
  # to appear in the logs. To fix this you need to add the Docker IP to
  # `allowed_ips`.
  #
  # https://github.com/rails/web-console#configuration
  # https://stackoverflow.com/a/29417509
  #
  # We only set the env var LOG_TO_STDOUT to 1 if running in a docker container
  # which is why our logic hinges on it
  if ENV.fetch("LOG_TO_STDOUT", "0") == "1"
    host_ip = `/sbin/ip route|awk '/default/ { print $3 }'`.strip
    config.web_console.allowed_ips = host_ip
  else
    config.web_console.allowed_ips = "127.0.0.1"
  end
end
