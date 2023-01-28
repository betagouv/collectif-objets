# frozen_string_literal: true

module Demos
  module Communes
    class Messagerie < Base
      def template = "communes/messages/index"
      def default_variant = "some_messages"

      def perform
        @new_message = build(:message, commune:)
        conservateur = build(:conservateur, first_name: "Léa", last_name: "Cafoutch")
        admin_user = build(:admin_user, first_name: "Patrice", last_name: "Arapède")
        @messages = [
          build(
            :message,
            text: "Comment s'appelle l'objet en question ?\n\nJe ne le trouve pas. Merci",
            author: current_user,
            commune:
          ),
          build(
            :message,
            text: "Il s'agit d'un calice en métal précieux de Carrare",
            author: conservateur,
            commune:
          ),
          build(
            :message,
            text: "Ok très clair, merci. Je n'arrive pas à uploader les photos par contre !",
            author: current_user,
            commune:
          ),
          build(
            :message,
            text: "Il vous suffit de cliquer sur le bouton ajouter, sur quel navigateur êtes-vous ?",
            author: admin_user,
            commune:
          )
        ]
      end
    end
  end
end
