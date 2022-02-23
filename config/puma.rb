# frozen_string_literal: true

# Config based on a mix of things taken from
# https://runnable.com/docker/rails/docker-configuration
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
# https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-puma-and-nginx-on-ubuntu-14-04
# Plus what we already found in the file

# Specifies the `port` that Puma will listen on to receive requests; default is 3000 to match rails.
port ENV.fetch("RAILS_PORT", 3000)

# Tells puma what environment we're running in. We always specify `RAILS_ENV=production` in our production environments
# which is why we default it to `development` for those environments where the env var isn't set.
environment ENV.fetch("RAILS_ENV", "development")

# Tell puma to use the pid file we're also managing in our entrypoint.sh. That way there should be no surprises.
pidfile "tmp/pids/server.pid"

# Puma can serve each request in a thread from an internal thread pool. The `threads` method setting takes two numbers:
# a minimum and maximum. The default is "0, 16". Based on some reading it is suggested that you should not allow your
# maximum to exceed the size of your database connection pool. As we are using ActiveRecord, the default is 5.
# https://devcenter.heroku.com/articles/concurrency-and-database-connections
threads 1, ENV.fetch("RAILS_MAX_THREADS", 5)
