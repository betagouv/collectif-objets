# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

gem "aasm"
gem "actioncable"
gem "activeadmin", "~> 2.11"
gem "active_model_validates_intersection_of"
gem "activerecord_where_assoc"
gem "active_storage_validations"
gem "after_commit_everywhere"
gem "aws-sdk-s3", require: false
gem "bootsnap", require: false
gem "devise", "~> 4.8"
gem "devise-i18n", "~> 1.10"
gem "draper", "~> 4.0"
gem "image_processing"
gem "matrix"
gem "pagy", "~> 5.10"
gem "pg", "~> 1.3"
gem "pg_search"
gem "prawn"
gem "prawn-table"
gem "puma", "~> 5.6"
gem "rails", "~> 7.0.1"
gem "sassc-rails"
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"
gem "sib-api-v3-sdk"
gem "sidekiq"
gem "skylight"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "view_component"
gem "vite_rails"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "factory_bot_rails"
  gem "launchy"
  gem "rspec-rails", "~> 5.1"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
end

group :development do
  gem "aasm-diagram", require: false
  gem "htmlbeautifier"
  gem "lookbook"
  gem "progressbar"
  gem "pry"
  gem "rails-erd", require: false
  gem "rubocop-daemon", require: false
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
