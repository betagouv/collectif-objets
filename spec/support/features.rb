# frozen_string_literal: true

# Feature specs configuration
# All feature specs use js: true because Axe needs JS to run

# Synchronization between Capybara commands and Turbo/fetch/script work in the
# browser is handled by capybara-lockstep (snippet in the application layout)

module JsHelpers
  def wait_until_js(condition)
    return unless page.driver.respond_to?(:evaluate_script)

    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.05 until page.evaluate_script(condition)
    end
  rescue Timeout::Error
    nil
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
  config.include JsHelpers, type: :feature
  config.include CapybaraDomId, type: :feature

  # Build assets once instead of letting vite's autoBuild re-hash all watched
  # files on every request, which slowed renders enough to exceed Capybara's
  # wait time under load
  config.before(:suite) do
    ViteRuby.commands.build
  end

  # Rails shares the database connection between the test thread and the
  # Capybara server thread, so feature specs run inside the default
  # transaction and need no truncation.

  config.before(type: :feature, js: true) do
    # Stub external services
    stub_request(:any, /tube.numerique.gouv.fr/).to_return(status: 200, body: "", headers: {})
    # Silence upstream deprecation warning. See https://github.com/teamcapybara/capybara/issues/2779
    Selenium::WebDriver.logger.ignore(:clear_local_storage, :clear_session_storage)
  end

  # Debug a feature spec visually/stop with pry by adding :debug
  config.before(type: :feature, debug: true) do
    Capybara.current_driver = :firefox
  end

  config.after(type: :feature, js: true) do |example|
    # Save screenshot only on failure, before Capybara resets the session
    if example.exception
      puts "saved screenshot to #{save_screenshot}" # rubocop:disable Lint/Debugger
    end

    # Reset the session now (rather than in capybara/rspec's own hook) so the
    # browser stops issuing requests, then let the server drain before the
    # wrapping transaction rolls back. A request can slip in between the
    # browser navigating away and Capybara's pending-requests check, and an
    # ActiveStorage variant request served after rollback raises
    # ForeignKeyViolation on the vanished blob, failing the next example.
    Capybara.reset_sessions!
    server = Capybara.current_session.server
    if server
      2.times do
        server.wait_for_pending_requests
        sleep 0.05
      end
    end

    # Clear Warden state to prevent leakage
    Warden.test_reset!
  end
end

Capybara.register_driver :headless_firefox do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  options.add_argument "-headless"
  # Keep confirm/alert dialogs open instead of auto-dismissing them, so
  # capybara-lockstep's synchronization scripts can't close them by accident
  options.unhandled_prompt_behavior = :ignore
  Capybara::Selenium::Driver.new app, browser: :firefox, options:
end

Capybara.register_driver :firefox do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  options.unhandled_prompt_behavior = :ignore
  Capybara::Selenium::Driver.new app, browser: :firefox, options:
end

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.unhandled_prompt_behavior = :ignore
  Capybara::Selenium::Driver.new app, browser: :chrome, options:
end

Capybara.server = :puma, { Silent: true }
Capybara.javascript_driver = ENV.fetch("CAPYBARA_JS_DRIVER", "headless_firefox").to_sym
Capybara.save_path = Rails.root.join("tmp/artifacts/capybara")

Capybara.default_max_wait_time = 10
Capybara.server_port = 31_337
