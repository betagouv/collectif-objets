# frozen_string_literal: true

module Co
  module AdminNotifications
    class ChatwootMessageNotification
      include Base

      def initialize(payload)
        @payload = payload
      end

      def icon_emoji
        "left_speech_bubble"
      end

      def message
        "[Message reçu sur Chatwoot](#{@payload['url']}) " \
          "de #{@payload[:sender_email]} : #{truncate(@payload[:content], length: 100)}"
      end
    end
  end
end
