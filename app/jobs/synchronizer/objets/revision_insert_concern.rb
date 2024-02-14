# frozen_string_literal: true

module Synchronizer
  module Objets
    module RevisionInsertConcern
      extend ActiveSupport::Concern

      def objet
        @objet ||= Objet.new(all_attributes)
      end

      private

      def create_or_update = :create

      def set_action_and_log
        @action = :create
        log "création de l’objet #{palissy_REF} avec #{objet_attributes.except(:palissy_REF)}"
      end
    end
  end
end
