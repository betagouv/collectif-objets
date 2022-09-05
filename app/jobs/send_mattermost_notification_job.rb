# frozen_string_literal: true

class MattermostApiError < StandardError; end

class SendMattermostNotificationJob
  include Sidekiq::Job

  HOOKS_URL = "https://mattermost.incubateur.net/hooks/#{Rails.application.credentials.mattermost&.hook_id}".freeze
  HANDLED_EVENTS = %w[commune_completed recensement_created].freeze

  def perform(event, payload)
    raise "unsupported event type #{event}" unless HANDLED_EVENTS.include?(event)

    @event = event.to_sym
    @payload = payload.with_indifferent_access
    return send_notification if Rails.configuration.x.environment_specific_name == "production"

    Sidekiq.logger.info { "would have sent mattermost notification #{body}" }
  end

  protected

  def send_notification
    res = Typhoeus.post(
      HOOKS_URL,
      headers: { "Content-Type" => "application/json" },
      body:
    )
    raise MattermostApiError, "status: #{res.response_code}" unless res.success?
  end

  def body
    {
      text: notification.message,
      attachments: notification.attachments,
      icon_emoji: notification.icon_emoji
    }.to_json
  end

  def notification
    @notification ||= notification_class_name.constantize.new(@payload)
  end

  def notification_class_name
    "Co::AdminNotifications::#{ActiveSupport::Inflector.classify(@event)}Notification"
  end
end
