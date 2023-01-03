# frozen_string_literal: true

module Co
  module AdminNotifications
    class DossierAutoSubmittedNotification
      include Base

      def initialize(payload)
        @dossier = Dossier.find(payload[:dossier_id])
      end

      def icon_emoji
        "checkered_flag"
      end

      def message
        "Le dossier ##{@dossier.id} de [#{@dossier.commune}](#{admin_commune_url(@dossier.commune)}) " \
          "a été automatiquement soumis (tous les objets recensés et dernier recensement il y a plus de 30 jours)"
      end
    end
  end
end
