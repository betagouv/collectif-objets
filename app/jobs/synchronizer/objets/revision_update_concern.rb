# frozen_string_literal: true

module Synchronizer
  module Objets
    module RevisionUpdateConcern
      extend ActiveSupport::Concern

      def objet
        @objet ||= begin
          persisted_objet.assign_attributes(all_attributes.except(*except_fields))
          persisted_objet
        end
      end

      def action # rubocop:disable Metrics/CyclomaticComplexity
        @action ||=
          if apply_commune_change?
            :update_with_commune_change
          elsif ignore_commune_change?
            :update_ignoring_commune_change
          elsif turns_in_scope?
            :update_turns_in_scope
          elsif ignore_turns_out_of_scope?
            :update_ignoring_turns_out_of_scope
          elsif turns_out_of_scope?
            :update_turns_out_of_scope
          elsif objet.changed?
            :update
          else
            :not_changed
          end
      end

      private

      def create_or_update = :update

      def import_row? = true

      def except_fields
        f = %i[palissy_REF]
        if ignore_commune_change?
          f += %i[
            palissy_COM
            palissy_INSEE
            palissy_DPT
            palissy_EDIF
            palissy_EMPL
            palissy_DEPL
            palissy_WEB
            palissy_MOSA
            lieu_actuel_code_insee
            lieu_actuel_edifice_nom
            lieu_actuel_edifice_ref
          ]
        end
        f += %i[in_scope in_scope_errors] if ignore_turns_out_of_scope?
        f
      end

      def existing_recensement?
        @existing_recensement ||= persisted_objet.recensements.any?
      end

      def commune_changed? = commune_before_update != commune_after_update
      def apply_commune_change? = commune_changed? && !existing_recensement?
      def ignore_commune_change? = commune_changed? && !apply_commune_change?

      def turns_in_scope? = !persisted_objet.in_scope && all_attributes[:in_scope]
      def turns_out_of_scope? = persisted_objet.in_scope && !all_attributes[:in_scope]
      def ignore_turns_out_of_scope? = turns_out_of_scope? && existing_recensement?

      def log_message # rubocop:disable Metrics/CyclomaticComplexity
        @log_message ||= begin
          m = "mise à jour de l’objet #{palissy_REF} : #{persisted_objet.changes}"
          case action
          when :update
            m
          when :update_turns_in_scope
            "#{m} - remis dans le scope de C"
          when :update_turns_out_of_scope
            "#{m} - sorti du scope de CO"
          when :update_ignoring_turns_out_of_scope
            "#{m} - sortie du scope de CO ignorée car l’objet a déjà un recensement"
          when :update_with_commune_change
            "#{m} - changement de commune appliqué #{commune_before_update} → #{commune_after_update || 'ø'} "
          when :update_ignoring_commune_change
            "#{m} - changement de commune ignoré #{commune_before_update} → #{commune_after_update || 'ø'} " \
            "car l’objet a déjà un recensement"
          end
        end
      end
    end
  end
end
