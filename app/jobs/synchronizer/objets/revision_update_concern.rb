# frozen_string_literal: true

module Synchronizer
  module Objets
    module RevisionUpdateConcern
      extend ActiveSupport::Concern

      def objet
        @objet ||= begin
          except_fields = ["REF"]
          except_fields += %w[COM INSEE DPT EDIF EMPL] if ignore_commune_change?
          attributes_to_assign = all_attributes.except(*except_fields.map { :"palissy_#{_1}" })
          persisted_objet.assign_attributes(attributes_to_assign)
          persisted_objet
        end
      end

      private

      def create_or_update = :update

      def existing_recensement?
        @existing_recensement ||= persisted_objet.recensements.any?
      end

      def commune_changed? = commune_before_update != commune_after_update
      def apply_commune_change? = commune_changed? && !existing_recensement?
      def ignore_commune_change? = commune_changed? && !apply_commune_change?

      def set_action_and_log
        message = "mise à jour de l’objet #{palissy_REF}"
        if apply_commune_change?
          message += " avec changement de commune appliqué #{commune_before_update} → #{commune_after_update} "
          @action = :update_with_commune_change
        elsif ignore_commune_change?
          message += " avec changement de commune ignoré #{commune_before_update} → #{commune_after_update} " \
                     "car l’objet a déjà un recensement associé"
          @action = :update_ignoring_commune_change
        else
          @action = :update
        end
        message += " : #{persisted_objet.changes}"
        log message
      end
    end
  end
end
