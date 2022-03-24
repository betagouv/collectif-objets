# frozen_string_literal: true

module Co
  module AdminNotifications
    class CommuneEnrolledNotification
      include Base

      def initialize(payload)
        @commune = Commune.find(payload[:commune_id])
      end

      def icon_emoji
        "round_pushpin"
      end

      def message
        "Commune inscrite ! " \
          "#{@commune.nom} (#{@commune.code_insee}) " \
          "· [voir dans l'admin](#{admin_url(@commune)})"
      end
    end
  end
end
