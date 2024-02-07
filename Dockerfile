################################################################################
# Generate base ruby stage
#
# Use alpine version to help reduce size of image and improve security (less things installed from the get go)
FROM ruby:2.7.1-alpine AS rails_base

LABEL org.opencontainers.image.description="The Strategic Review of Charges (SROC) Tactical Charging Module (TCM) is a web application designed to enable billing adminstrators to apply new categories to permit charges to ensure correct amounts are processed."

# If set bundler will install all gems to this location. In our case we want a known location so we can easily copy the
# installed and compiled gems between images
ENV BUNDLE_PATH=/usr/src/gems

# When the app is run in a container we need the logs to be written to STDOUT and not the default of log/production.log.
# The app doesn't really care about the value of the env var, simply that it exists. If it does the app will set its
# logger to use STDOUT.
ENV LOG_TO_STDOUT=1

# Ensure we have updated whatever packages come as part of the alpine image before we start using it. This was a
# requirement following PEN testing. We also add the dependencies we need to support using PostgreSQL. Finish with
# clearing the cache created during this to keep the image as small as possible (using Docker we can't benefit from
# using the cache)
RUN apk update && apk add \
  postgresql-client \
  nodejs \
  tzdata \
  && rm -rf /var/cache/apk/*

# Create a system user to ensure when the final image is run as a container we don't run as root, which is considered a
# security violation
RUN addgroup -S appgroup && adduser -S app -G appgroup

# force_ruby_platform:- Ignore the current machine's platform and install only ruby platform gems. As a result, gems
# with native extensions will be compiled from source. This helps ensure the gems are built for this image
RUN gem install bundler -v 2.4.22 \
  && bundle config force_ruby_platform true

################################################################################
# Stage used to build and install gems
#
# By building it in this stage it means we can avoid having to install dependencies we only need when running `bundle
# install` into the final image. This keeps the size down and is more secure. Also, as changes to the gems are less
# frequent that changes to the code, it means most builds can benefit from this layer being cached.
FROM rails_base AS gem_builder

# Set out working directory (no need to create it first)
WORKDIR /usr/src/app

# Install just the things we need to be able to run `bundle install` and compile any gems with native extensions such as
# Nokogiri
#   - `--no-cache` Don't cache the index locally. Equivalent to `apk update` in the beginning and
#     `rm -rf /var/cache/apk/*` at the end
#   - `--virtual build-dependencies` Tag the installed packages as a group which can then be used to quickly remove them
#     when done with
RUN apk add --no-cache --virtual build-dependencies build-base ruby-dev postgresql-dev

# Install the gems
# Assuming we are in the root of the project copy the Gemfiles across. By just copying these we'll only cause this layer
# to rebuild if those files have changed
COPY Gemfile Gemfile.lock ./
# We specifically don't use the `--without development test`. This is as a result of reading an article which
# recommended avoiding doing so. For the sake of a slightly larger image we have a much more reusable and cacheable
# builder stage.
#   - `rm -rf /usr/src/gems/cache/*.gem` Remove the cache. If anything changes Docker will rebuild the whole layer so a
#     cache is pointless
RUN bundle install \
  && rm -rf /usr/src/gems/cache/*.gem

# Uninstall those things we added just to be able to run `bundle install`
#   - `--no-cache` Same as `add` it stops the index being cached locally
#   - `build-dependencies` Virtual name given to a group of packages when installed
RUN apk del --no-cache build-dependencies

################################################################################
# Stage used to pre-compile assets
#
# Works in the similar way as the gem_builder stage. It is not about managing the dependencies we need to install gems.
# It is about splitting the work of building gems and assets. We only need to pre-compile the assets when building a
# production image. A development image automatically generates the assets on the fly. This is how we're able to make
# changes and see them immediately in the UI when developing
FROM gem_builder AS asset_builder

# Because the airbrake gem is expect to be used in all environments its initializer (config/initializers/errbit.rb) is
# called which expects AIRBRAKE_HOST and AIRBRAKE_KEY to be present. Unfortunately, this is the case even when we are
# just trying to generate the assets. So, to avoid an error during the build we set this to dummy values in this
# stage. Real values will need to be provided when a container is started else the app will error.
ENV AIRBRAKE_HOST=https://my-errbit-instance.com
ENV AIRBRAKE_KEY=013b84e1-7b97-4779-9526-c754d423e8b3

WORKDIR /usr/src/app

# Pre-compile the assets
# Ideally wwe would just copy across the files needed to run `rake assets:precompile`. At a minimum we have found that
# to be the config/ folder and Rakefile plus the app/assets and public/ folders. But if you have custom tasks that
# reference your code then you'll need various files from app/ (services, models etc). In which case it's simpler to
# just copy the whole project across
COPY . .

# Compile the assets in /public/assets
RUN bundle exec rake assets:precompile

################################################################################
# Create production rails [app] (final stage)
#
FROM rails_base AS production

# Version information for the app. The app will use this information to let us the delivery team know exactly what
# version we are running. The ARG value needs to be provided to make the value available during build. The ENV will
# then get baked into the image and made available whenever a container is started. It is the responsibility of
# whatever calls `docker build` to supply the GIT_COMMIT build arg.
ARG GIT_COMMIT
ENV GIT_COMMIT=$GIT_COMMIT

# Set the rails environment variable
ENV RAILS_ENV=production

# Our chosen root directory for the app in the image
WORKDIR /usr/src/app

# Assuming we are in the root of the project, copy all the code (excluding whatever is in .dockerignore) into the
# current directory (which is WORKDIR)
COPY . .

# Remove app code we don't actually need or when the app is run in production, plus the public folder as we're grabbing
# that out of rails_builder
# RUN rm -rf spec test app/assets vendor/assets tmp public

# Copy the gems generated in the gem_builder stage from its image to this one
COPY --from=gem_builder /usr/src/gems /usr/src/gems
# Copy the assets in the asset_builder stage from its image to this one
COPY --from=asset_builder /usr/src/app/public /usr/src/app/public

# This should be set in the project but just in case we ensure entrypoint.sh is executable
RUN chmod +x entrypoint.sh

# Ensure our app user (non-root user) will be able to write to the tmp folder. This is needed by rails and puma to
# create pid session files, plus the cache and log files they generate
# Change onwership of the folder from root to app, and the group to app's group (appgroup)
RUN chown -R app: tmp

# Specifiy listening port for the container
EXPOSE 3000

# Set the user to app instead of root. From this point on all commands will be run as the app user, even when you
# `docker exec` into the container
USER app

# This script will _always_ be run when a container is started. In the event we are restarting an existing container
# there is a chance the `tmp/pids/server.pid` from the previous run remains. If left it would cause the app to error
# with 'server already running'
ENTRYPOINT [ "./entrypoint.sh" ]

# This is the default cmd that will be run if an alternate is not passed in at the command line.
# Use the "exec" form of CMD so rails shuts down gracefully on SIGTERM (i.e. `docker stop`)
CMD [ "bundle", "exec", "puma" ]
