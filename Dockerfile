# syntax=docker/dockerfile:1
FROM ruby:3.4.5-slim

EXPOSE 3000

RUN apt-get update -qq && apt-get install --no-install-recommends -y build-essential libpq-dev postgresql-client curl libvips42 nodejs npm

WORKDIR /app

COPY Gemfile Gemfile.lock .
RUN bundle install

WORKDIR /app
COPY package.json package-lock.json .
RUN npm i

COPY . .

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
