#!/bin/sh
set -e
rm -f tmp/pids/server.pid
bundle exec rails db:prepare
if [ "$SEED_ON_BOOT" = "true" ]; then bundle exec rails db:seed; fi
exec "$@"
