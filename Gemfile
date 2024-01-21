# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"

gem "aasm", "~> 5.5"
gem "actioncable", "~> 7.1"
gem "active_model_validates_intersection_of", "~> 3.0"
gem "activerecord-postgis-adapter", "~> 9.0"
gem "active_storage_validations", "~> 1.1"
gem "after_commit_everywhere", "~> 1.3"
gem "aws-sdk-s3", "~> 1.132", require: false
gem "bootsnap", "~> 1.17", require: false
gem "devise", "~> 4.9"
gem "dsfr-view-components", "~> 0.4"
gem "factory_bot_rails", "~> 6.2"
gem "front_matter_parser", "~> 1.0"
gem "haml-rails", "~> 2.1"
gem "icalendar", "~> 2.10"
gem "image_processing", "~> 1.12"
gem "kramdown", "~> 2.4"
gem "matrix", "~> 0.4"
gem "mjml-rails", "~> 4.9"
gem "pagy", "~> 6.0"
gem "pg", "~> 1.5"
gem "prawn", "~> 2.4"
gem "prawn-table", "~> 0.2"
gem "progressbar", "~> 1.0"
gem "puma", "~> 6.4"
gem "pundit", "~> 2.3"
gem "rails", "~> 7.1"
gem "ransack", "~> 4.1"
gem "redis", "~> 5.0"
gem "rubyzip", "~> 2.3"
gem "sentry-rails", "~> 5.15"
gem "sentry-ruby", "~> 5.15"
gem "sentry-sidekiq", "~> 5.15"
gem "sidekiq", "~> 7.2"
gem "turbo-rails", "~> 1.4"
gem "typhoeus", "~> 1.4"
gem "tzinfo-data", "~> 1.0", platforms: %i[mingw mswin x64_mingw jruby]
gem "view_component", "~> 2.83"
gem "vite_rails", "~> 3.0"

group :development, :test do
  gem "debug", ">= 1.0"
  gem "launchy", "~> 2.5"
  gem "rspec-rails", "~> 6.1"
  gem "rubocop", "~> 1.51", require: false
  gem "rubocop-rails", "~> 2.19", require: false
end

group :development do
  gem "aasm-diagram", "~> 0.1", require: false
  gem "foreman", "~> 0.87"
  gem "html2haml", "~> 2.3"
  gem "htmlbeautifier", "~> 1.4"
  gem "pry", "~> 0.14"
  gem "rails-erd", "~> 1.7", require: false
  gem "solargraph", "~> 0.49"
  gem "web-console", "~> 4.2"
end

group :test do
  gem "axe-core-capybara", "~> 4.7"
  gem "axe-core-rspec", "~> 4.8"
  gem "capybara", "~> 3.39"
  gem "selenium-webdriver", "~> 4.16"
end
