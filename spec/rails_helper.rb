# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

# Add additional requires below this line. Rails is not loaded until this point!
require "axe-rspec"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = Rails.root.join("/spec/fixtures")
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  # config.filter_gems_from_backtrace("gem name")

  config.include Warden::Test::Helpers
  
  if ENV["CAPYBARA_OPEN_PAGE_ON_FAIL"]
    config.after do |example_group|
      save_and_open_page if example_group.exception # rubocop:disable Lint/Debugger
    end
  end
end

Capybara.register_driver :headless_firefox do |app|
  options = Selenium::WebDriver::Firefox::Options.new.tap(&:headless!)
  Capybara::Selenium::Driver.new app, browser: :firefox, options:
end
Capybara.register_driver :firefox do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  Capybara::Selenium::Driver.new app, browser: :firefox, options:
end
Capybara.javascript_driver = ENV.fetch("CAPYBARA_JS_DRIVER", "headless_firefox").to_sym

# rubocop:disable Lint/SuppressedException
begin
  require "pry"
rescue LoadError
end
# rubocop:enable Lint/SuppressedException
