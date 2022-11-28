# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

gem "aasm"
gem "actioncable"
gem "activeadmin", "~> 2.11"
gem "active_model_validates_intersection_of"
gem "activerecord-postgis-adapter"
gem "activerecord_where_assoc"
gem "active_storage_validations"
gem "after_commit_everywhere"
gem "aws-sdk-s3", require: false
gem "bootsnap", require: false
gem "devise", "~> 4.8"
gem "devise-i18n", "~> 1.10"
gem "draper", "~> 4.0"
gem "factory_bot_rails"
gem "image_processing"
gem "matrix"
gem "pagy", "~> 5.10"
gem "pg", "~> 1.4"
gem "pg_search"
gem "prawn"
gem "prawn-table"
gem "progressbar"
gem "puma", "~> 6.0"
gem "pundit"
gem "rails", "~> 7.0.4"
gem "sassc-rails"
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"
gem "sidekiq"
gem "sidekiq-throttled"
gem "slim"
gem "sprockets-rails"
gem "turbo-rails"
gem "typhoeus"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "view_component"
gem "vite_rails"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "launchy"
  gem "rspec-rails", "~> 6.0"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
end

group :development do
  gem "aasm-diagram", require: false
  gem "htmlbeautifier"
  gem "lookbook"
  gem "pry"
  gem "rails-erd", require: false
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

gem "mjml-rails", "~> 4.8"
