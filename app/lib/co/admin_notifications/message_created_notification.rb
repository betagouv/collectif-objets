# frozen_string_literal: true

module Co
  module AdminNotifications
    class MessageCreatedNotification
      include Base

      def initialize(payload)
        @message = Message.find(payload[:message_id])
      end

      def icon_emoji = "envelope"

      def message
        "Nouveau message #{origin}  #{author_str} :\n\n#{body_quoted}\n\n" \
          "#{ar_message.files.count} fichier(s) attaché(s)\n\n" \
          "[voir dans l'admin](#{admin_commune_url(commune)})"
      end

      def channel = "projet-collectif_objets-notifications-support"

      private

      delegate :commune, :origin, :author, :inbound_email, :web?, to: :ar_message

      def author_str
        case author
        when User
          "de la commune #{commune.nom} (#{commune.code_insee})"
        when Conservateur
          "du conservateur #{author} pour la commune #{commune.nom} (#{commune.code_insee})"
        end
      end

      def ar_message = @message

      def body
        return ar_message.text if web?

        return "*contenu vide*" if inbound_email.body_md.blank?

        inbound_email.body_md
      end

      def body_quoted
        body.lines.map { "> #{_1}" }.join("\n")
      end
    end
  end
end
