# frozen_string_literal: true

# Feature specs configuration
# All feature specs use js: true because Axe needs JS to run

module TurboHelpers
  def wait_for_turbo
    return unless page.driver.respond_to?(:evaluate_script)

    Timeout.timeout(Capybara.default_max_wait_time) do
      turbo_idle = "typeof Turbo === 'undefined' || " \
                   "(!Turbo.navigator.currentVisit || Turbo.navigator.currentVisit.state !== 'started') && " \
                   "!document.documentElement.hasAttribute('data-turbo-preview')"
      sleep 0.05 until page.evaluate_script(turbo_idle)
    end
  rescue Timeout::Error
    nil
  end

  def click_on(...)
    super
    wait_for_turbo
  end

  def click_button(...)
    super
    wait_for_turbo
  end

  def click_link(...)
    super
    wait_for_turbo
  end
end

module CapybaraDomId
  def dom_id(element)
    "##{action_view_dom_id(element)}"
  end

  def action_view_dom_id(element)
    ActionView::RecordIdentifier.dom_id(element)
  end
end

RSpec.configure do |config|
  config.include TurboHelpers, type: :feature
  config.include CapybaraDomId, type: :feature

  # Rails shares the database connection between the test thread and the
  # Capybara server thread, so feature specs run inside the default
  # transaction and need no truncation.

  config.before(type: :feature, js: true) do
    # Stub external services
    stub_request(:any, /tube.numerique.gouv.fr/).to_return(status: 200, body: "", headers: {})
    # Silence upstream deprecation warning. See https://github.com/teamcapybara/capybara/issues/2779
    Selenium::WebDriver.logger.ignore(:clear_local_storage, :clear_session_storage)
  end

  config.after(type: :feature, js: true) do |example|
    # Save screenshot only on failure, before Capybara resets the session
    if example.exception
      puts "saved screenshot to #{save_screenshot}" # rubocop:disable Lint/Debugger
    end

    # Clear Warden state to prevent leakage
    Warden.test_reset!
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
