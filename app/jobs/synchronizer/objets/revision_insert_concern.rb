# frozen_string_literal: true

module Synchronizer
  module Objets
    module RevisionInsertConcern
      extend ActiveSupport::Concern

      def objet
        @objet ||= Objet.new(all_attributes)
      end

      def action = :create

      private

      def create_or_update = :create

      def log_message = "création de l’objet #{palissy_REF} avec #{all_attributes.except(:palissy_REF)}"
    end
  end
end
