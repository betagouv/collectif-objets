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
  config.fixture_paths = [Rails.root.join("/spec/fixtures")]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  # config.filter_gems_from_backtrace("gem name")

  config.include Warden::Test::Helpers
  config.before(:suite) { require Rails.root.join("scripts/create_postgres_sequences_memoire_photos_numbers.rb") }

  require "webmock/rspec"
  WebMock.disable_net_connect!(allow_localhost: true)
  config.before(type: :feature) do
    stub_request(:any, /tube.numerique.gouv.fr/).to_return(status: 200, body: "", headers: {})
    # Silence upstream deprecation warning. See https://github.com/teamcapybara/capybara/issues/2779
    Selenium::WebDriver.logger.ignore(:clear_local_storage, :clear_session_storage)
  end

  config.after(type: :feature) do |example_group|
    next unless example_group.exception

    r = save_screenshot
    puts "saved screenshot to #{r}"
  end
end

Capybara.register_driver :headless_firefox do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  options.add_argument "-headless"
  Capybara::Selenium::Driver.new app, browser: :firefox, options:
end

Capybara.register_driver :firefox do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  Capybara::Selenium::Driver.new app, browser: :firefox, options:
end

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  Capybara::Selenium::Driver.new app, browser: :chrome, options:
end

Capybara.server = :puma, { Silent: true }
Capybara.javascript_driver = ENV.fetch("CAPYBARA_JS_DRIVER", "headless_firefox").to_sym
Capybara.save_path = Rails.root.join("tmp/artifacts/capybara")

Capybara.default_max_wait_time = 10
Capybara.server_port = 31337
