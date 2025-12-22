# frozen_string_literal: true

# Feature specs configuration
# All feature specs use js: true because Axe needs JS to run

module CapybaraDomId
  def dom_id(element)
    "##{action_view_dom_id(element)}"
  end

  def action_view_dom_id(element)
    ActionView::RecordIdentifier.dom_id(element)
  end
end

RSpec.configure do |config|
  config.include CapybaraDomId, type: :feature

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(type: :feature, js: true) do |example|
    # Feature specs require special database handling due to running in separate threads
    self.use_transactional_tests = false
    DatabaseCleaner.strategy = :truncation

    # Stub external services
    stub_request(:any, /tube.numerique.gouv.fr/).to_return(status: 200, body: "", headers: {})
    # Silence upstream deprecation warning. See https://github.com/teamcapybara/capybara/issues/2779
    Selenium::WebDriver.logger.ignore(:clear_local_storage, :clear_session_storage)

    DatabaseCleaner.cleaning do
      example.run

      # Reset Capybara sessions and wait for server to finish processing requests
      # BEFORE database cleanup to prevent race conditions with ActiveStorage variant creation
      Capybara.reset_sessions!
      # Wait for all in-flight HTTP requests (especially variant image requests) to complete
      # before truncating the database
      sleep 0.5
    end

    # Clear Warden state to prevent leakage
    Warden.test_reset!

    # Save screenshot only on failure
    if example.exception
      puts "saved screenshot to #{save_screenshot}" # rubocop:disable Lint/Debugger
    end

    self.use_transactional_tests = true
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
