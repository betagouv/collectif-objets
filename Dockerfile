# syntax=docker/dockerfile:1
ARG RUBY_VERSION
FROM ruby:${RUBY_VERSION}-slim
COPY .ruby-version /tmp/.ruby-version
RUN PROJECT_RUBY_VERSION=$(cat /tmp/.ruby-version | tr -d '\n\r ') && \
    ARGUMENT_RUBY_VERSION=$(echo "$RUBY_VERSION" | tr -d '\n\r ') && \
    if [ "$ARGUMENT_RUBY_VERSION" != "$PROJECT_RUBY_VERSION" ]; then \
        echo "❌ Ruby version mismatch!"; \
        echo "   Project requires: $PROJECT_RUBY_VERSION (from .ruby-version)"; \
        echo "   Build argument:   $ARGUMENT_RUBY_VERSION (from RUBY_VERSION)"; \
        echo "   Please update RUBY_VERSION argument: docker build --build-arg RUBY_VERSION=$PROJECT_RUBY_VERSION"; \
        exit 1; \
    else \
        echo "✅ Ruby version: $ACTUAL_VERSION"; \
    fi

EXPOSE 3000

RUN apt-get update -qq \
    && apt-get install \
    -y --no-install-recommends \
    build-essential libpq-dev postgresql-client \
    curl libvips42 \
    nodejs npm

WORKDIR /app

COPY Gemfile Gemfile.lock /app/
RUN bundle install

WORKDIR /app
COPY package.json package-lock.json /app/
RUN npm i

COPY . .

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
