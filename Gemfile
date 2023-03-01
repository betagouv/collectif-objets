# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

gem "aasm"
gem "actioncable"
gem "active_model_validates_intersection_of"
gem "activerecord-postgis-adapter"
gem "activerecord_where_assoc"
gem "active_storage_validations"
gem "after_commit_everywhere"
gem "aws-sdk-s3", require: false
gem "bootsnap", require: false
gem "devise", "~> 4.8"
gem "devise-i18n", "~> 1.11"
gem "dsfr-view-components"
gem "factory_bot_rails"
gem "front_matter_parser"
gem "haml-rails"
gem "icalendar"
gem "image_processing"
gem "kramdown"
gem "matrix"
gem "mjml-rails", "~> 4.8"
gem "pagy", "~> 6.0"
gem "pg", "~> 1.4"
gem "pg_search"
gem "progressbar"
gem "puma", "~> 6.1"
gem "pundit"
gem "rails", "~> 7.0.4"
gem "ransack"
gem "ratonvirus"
gem "redis"
gem "rubyzip"
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"
gem "sidekiq"
gem "turbo-rails"
gem "typhoeus"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "view_component"
gem "vite_rails"
gem "ratonvirus-clamby"

group :development, :test do
  gem "debug", ">= 1.0.0"
  gem "launchy"
  gem "rspec-rails", "~> 6.0"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
end

group :development do
  gem "aasm-diagram", require: false
  gem "foreman"
  gem "html2haml"
  gem "htmlbeautifier"
  gem "listen" # for lookbook
  gem "lookbook", "~> 2.0.0.beta.3"
  gem "pry"
  gem "rails-erd", require: false
  gem "web-console"
end

group :test do
  gem "axe-core-capybara"
  gem "axe-core-rspec"
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
