FROM ruby:3.2-slim

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential libpq-dev libvips curl nodejs git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile Gemfile.lock* ./
RUN bundle install

COPY . .
RUN SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rails assets:precompile

ENV RAILS_ENV=production RAILS_SERVE_STATIC_FILES=1 RAILS_LOG_TO_STDOUT=1
EXPOSE 3000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-b", "tcp://0.0.0.0:3000"]
