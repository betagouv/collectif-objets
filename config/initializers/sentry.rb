Sentry.init do |config|
  return unless Rails.env.production?

  config.dsn = 'https://5f6f9cf638ac413b82d1d9c8a9ba2025@sentry.incubateur.net/40'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.005

  config.environment = Rails.configuration.x.environment_specific_name

  config.sidekiq.report_after_job_retries = true

  config.release = ENV["CONTAINER_VERSION"] if ENV["CONTAINER_VERSION"].present?
end
