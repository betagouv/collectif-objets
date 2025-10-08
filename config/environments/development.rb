# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.default_url_options = { host: 'localhost', port: 3000 }

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :scaleway_development

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV.fetch("MAILHOG_HOST", '127.0.0.1'),
    port: 1025
  }
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  # config.action_mailer.default_url_options = { host: "localhost:3000" }
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   :address => "smtp-relay.sendinblue.com",
  #   :port => 587,
  #   :user_name => Rails.application.credentials.sendinblue.smtp.username,
  #   :password => Rails.application.credentials.sendinblue.smtp.password,
  #   :authentication => 'login',
  #   :enable_starttls_auto => true,
  #   return_response: true
  # }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  config.x.environment_specific_name = "development"
  config.x.inbound_emails_domain = "reponse-loophole.collectifobjets.org"

  config.hosts += %w[collectifobjets.loophole.site collectifobjets-mail-inbound.loophole.site]
  config.hosts << ENV["GITPOD_WORKSPACE_URL"].gsub("https://", "") if ENV["GITPOD_WORKSPACE_URL"].present?

  config.log_file_size = 100_000_000

  config.view_component.preview_paths += [Rails.root.join("app/components/")]
end
