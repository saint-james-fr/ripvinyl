# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.1.2
FROM ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_ENV="production"

# Update gems and bundler
RUN gem update --system --no-document && \
    gem install -N bundler

# JavaScript build stage
FROM node:20-slim as javascript

WORKDIR /app

# Copy JavaScript-related files
COPY --link package.json yarn.lock ./

# Install JavaScript dependencies and build assets
RUN npm install -g yarn && \
    yarn install --frozen-lockfile

COPY --link . .

# Build JavaScript assets (adjust this command based on your build script)
RUN yarn build

# Ruby build stage
FROM base as build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    git \
    pkg-config \
    cmake \
    libssl-dev

# Copy application code
COPY --link . .
COPY --link Gemfile Gemfile.lock ./

# Install Ruby dependencies
RUN bundle config set --local without 'development test' && \
    bundle install --jobs $(nproc) && \
    bundle exec bootsnap precompile --gemfile && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy JavaScript assets from javascript stage
COPY --from=javascript /app/app/assets ./app/assets
COPY --from=javascript /app/public ./public

# Precompile bootsnap and assets
RUN bundle exec bootsnap precompile app/ lib/ && \
    bundle exec rails assets:precompile

# Final stage
FROM base

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    postgresql-client \
    libpq5 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Setup user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R 1000:1000 db log storage tmp
USER 1000:1000

# Entrypoint and CMD
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["./bin/rails", "server"]