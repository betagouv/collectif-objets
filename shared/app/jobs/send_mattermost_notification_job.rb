# frozen_string_literal: true

class MattermostApiError < StandardError; end

class SendMattermostNotificationJob
  include Sidekiq::Job
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  HOOKS_URL = "https://mattermost.incubateur.net/hooks/#{Rails.application.credentials.mattermost.hook_id}".freeze

  def perform(event, payload)
    @payload = payload.with_indifferent_access
    @event = event.to_sym
    return send_notification if Rails.configuration.x.environment == "production"

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
    { text: message, attachments:, icon_emoji: }.to_json
  end

  def attachments
    return [{ image_url: photo_url(recensement.photos.first) }] \
      if @event == :recensement_created && recensement.photos.any?

    []
  end

  def icon_emoji
    case @event
    when :recensement_created
      "writing_hand"
    when :commune_enrolled
      "round_pushpin"
    end
  end

  def photo_url(attachment)
    "https://#{Rails.application.default_url_options[:host]}#{rails_blob_path(attachment)}"
  end

  def message
    case @event
    when :recensement_created
      recensement_created_message
    when :commune_enrolled
      commune_enrolled_message
    end
  end

  # rubocop:disable Metrics/AbcSize
  def recensement_created_message
    "Nouveau recensement " \
      "· [admin](#{admin_url(recensement)}) ! " \
      "Commune #{recensement.commune.nom} (#{recensement.commune.code_insee}) " \
      "· [admin](#{admin_url(recensement.commune)}) " \
      "- Objet #{truncate(recensement.objet.nom, length: 30)} " \
      "· [admin](#{admin_url(recensement.objet)}) " \
      "- #{recensement.photos.any? ? "#{recensement.photos.count} photos" : '❌ Photos absentes'}"
  end
  # rubocop:enable Metrics/AbcSize

  def commune_enrolled_message
    commune = Commune.find(@payload[:commune_id])
    "Commune inscrite ! " \
      "#{commune.nom} (#{commune.code_insee}) " \
      "· [voir dans l'admin](#{admin_url(commune)})" \
  end

  def recensement
    @recensement ||= Recensement.find(@payload[:recensement_id])
  end

  def admin_url(resource)
    "#{Rails.configuration.x.admin_host}admin/#{resource.class.table_name}/#{resource.id}"
  end
end
