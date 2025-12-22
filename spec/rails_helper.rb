# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

# Add additional requires below this line. Rails is not loaded until this point!
require "axe-rspec"
require "database_cleaner/active_record"

Rails.root.glob("spec/support/**/*.rb").each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  # config.filter_gems_from_backtrace("gem name")

  config.fixture_paths = [Rails.root.join("/spec/fixtures")]

  config.use_transactional_fixtures = true

  config.include Warden::Test::Helpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Rails.application.routes.url_helpers, type: :request

  # Add app-specific columns to ActiveStorage
  config.before(:suite) { require Rails.root.join("scripts/create_postgres_sequences_memoire_photos_numbers.rb") }
end

require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)
