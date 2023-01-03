# frozen_string_literal: true

module Co
  module AdminNotifications
    class RecensementCreatedNotification
      include Base

      def initialize(payload)
        @recensement = Recensement.find(payload[:recensement_id])
      end

      def icon_emoji
        "writing_hand"
      end

      def message
        "Nouveau recensement !" \
          "[Commune #{@recensement.commune}](#{admin_commune_url(@recensement.commune)})" \
          "- Objet #{truncate(@recensement.objet.nom, length: 30)} " \
          "- #{@recensement.photos.any? ? "#{@recensement.photos.count} photos" : '❌ Photos absentes'}"
      end

      def attachments
        return [] if @recensement.photos.empty?

        [{ image_url: @recensement.photos.first.variant(:medium).processed.url(expires_in: 1.day) }]
      end
    end
  end
end
