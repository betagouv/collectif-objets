Sentry.init do |config|
  return unless Rails.env.production?

  config.dsn = ENV.fetch("SENTRY_DSN", Rails.application.credentials.sentry.dsn)
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.005

  config.environment = Rails.configuration.x.environment_specific_name

  config.release = ENV["CONTAINER_VERSION"] if ENV["CONTAINER_VERSION"].present?
end
