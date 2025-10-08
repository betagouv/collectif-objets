# frozen_string_literal: true

require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.default_url_options = { host: 'localhost', port: 31337 }

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.active_job.queue_adapter = :test

  # Turn false under Spring and add config.action_view.cache_template_loading = true.
  config.cache_classes = true

  # Disable logging to speed up tests
  config.logger = Logger.new(nil)
  config.log_level = :fatal

  # Eager loading loads your whole application. When running a single test locally,
  # this probably isn't necessary. It's a good idea to do in a continuous integration
  # system, or in some way before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  config.action_dispatch.show_exceptions = :rescuable
  config.action_dispatch.rescue_responses.merge!({
    "OnPurposeError" => :internal_server_error
  })

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  config.x.inbound_emails_domain = "reponse-test.collectifobjets.org"

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Enable ActiveRecord encryption (without credentials)
  config.active_record.encryption.primary_key = "test_primary_key"
  config.active_record.encryption.deterministic_key = "test_deterministic_key"
  config.active_record.encryption.key_derivation_salt = "test_salt"
end
