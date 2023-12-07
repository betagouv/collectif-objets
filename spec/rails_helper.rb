# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

# Add additional requires below this line. Rails is not loaded until this point!
require 'capybara/rspec'
require "capybara/cuprite"
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
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  # config.filter_gems_from_backtrace("gem name")

  config.include Warden::Test::Helpers

  config.after(type: :feature) do |example_group|
    next unless example_group.exception
    path = save_screenshot
    puts "DEBUG: screenshot saved to #{path}"
  end
end

Capybara.raise_server_errors = true
Capybara.save_path = Rails.root.join("tmp/artifacts/capybara")
Capybara.javascript_driver = :cuprite
Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(app, window_size: [1920, 1080])
end

Capybara.default_max_wait_time = 10

begin
  require "pry"
rescue LoadError
end
