# frozen_string_literal: true

module Co
  module AdminNotifications
    class DossiersAutoSubmittedNotification
      include Base

      def initialize(payload)
        @dossiers = Dossier.where(id: payload[:dossiers_id]).includes(:commune)
      end

      def icon_emoji
        "checkered_flag"
      end

      def message
        "Les dossiers suivants ont été automatiquement soumis (tous les objets recensés et dernier recensement " \
          "il y a plus de 30 jours) :\n#{dossiers_list}"
      end

      private

      def dossiers_list
        @dossiers.map { "- Dossier ##{_1.id} - #{_1.commune}" }.join("\n")
      end
    end
  end
end
