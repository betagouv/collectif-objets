Sentry.init do |config|
  return unless Rails.env.production?

  config.dsn = 'https://29778c73190d4c4db4c3369d6ed15df7@o103100.ingest.sentry.io/6204702'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 1.0

  if ENV["HOST"] =~ /staging/
    config.environment = 'staging'
  end
end
