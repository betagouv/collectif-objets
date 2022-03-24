# frozen_string_literal: true

module Co
  module AdminNotifications
    class CommuneCompletedNotification
      include Base

      def initialize(payload)
        @commune = Commune.find(payload[:commune_id])
      end

      def icon_emoji
        "checkered_flag"
      end

      def message
        "La commune #{@commune.nom} (#{@commune.code_insee}) " \
          "a terminé son recensement. " \
          "[voir dans l'admin](#{admin_url(@commune)})"
      end
    end
  end
end
