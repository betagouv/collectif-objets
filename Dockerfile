# syntax=docker/dockerfile:1
FROM ruby:3.1.2
RUN apt-get update -qq && apt-get install --no-install-recommends -y postgresql-client libvips42
WORKDIR /app

COPY Gemfile Gemfile.lock .
RUN bundle install

# install node 18, debian 11 (bullseye) comes with nodejs 12 default
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
RUN apt-get install -y nodejs

COPY package.json package-lock.json .
RUN npm i

COPY . .
CMD bundle exec rails server -p 3000 -b '0.0.0.0'
