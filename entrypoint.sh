#!/bin/sh

# Safer shell execution
# -e If a command fails, set -e will make the whole script exit, instead of just
#    resuming on the next line
# -u Treat unset variables as an error, and immediately exit
# -x Print each command before executing it (arguments will be expanded)
set -eux

# When a running container is stopped using ctrl+c in the terminal (something we do often when working locally) the
# running process is killed before rails can remove the pid file. Then, when we next start the app we get an error.
# Because we bind mount the local folder into the host it means the pid file from the last run is still there and puma
# chucks a 'server is already running error'.
#
# The alternatives to this are to remember to manually delete the file before calling docker-compose up, or always using
# docker-compose stop instead of ctrl+c. If we were running on an actual instance just deleting the pid file no matter
# what would be a big no-no. But as we are dealing with containers and this script is only being called when first
# started there will never we a scenario where the app is already running. So, this is primarily to make our local
# development lives easier. But we also use the script in production as it keeps things consistent and there is no risk.
#
# Thanks https://stackoverflow.com/a/38732187 for the solution
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
