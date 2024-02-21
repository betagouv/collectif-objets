# frozen_string_literal: true

module Synchronizer
  module Objets
    module Revision
      module UpdateConcern
        extend ActiveSupport::Concern

        def objet
          @objet ||= persisted_objet.tap { _1.assign_attributes(all_attributes) }
        end

        def synchronize
          return false if row.out_of_scope? || !objet_valid?

          log log_message, counter: action

          return true if action == :not_changed

          ActiveRecord::Base.transaction do
            destroy_or_soft_delete_existing_recensement! if commune_changed? && existing_recensement
            objet.save!
          end
          true
        end

        private

        def action
          @action ||=
            if commune_changed? && existing_recensement
              :update_with_commune_change_recensement_deleted
            elsif commune_changed?
              :update_with_commune_change
            elsif objet.changed?
              :update
            else
              :not_changed
            end
        end

        def objet_valid?
          return true if objet.valid?

          log "mise à jour de l'objet #{palissy_REF} rejeté car l’objet n'est pas valide " \
              ": #{objet.errors.full_messages.to_sentence} - #{all_attributes}",
              counter: :update_rejected_invalid
          false
        end

        def existing_recensement
          @existing_recensement ||= persisted_objet.recensements.first
        end

        def commune_after_update = @eager_loaded_records.commune
        def commune_changed? = commune_before_update != commune_after_update

        def commune_change_message
          "changement de commune appliqué #{commune_before_update} → #{commune_after_update || 'ø'}"
        end

        def destroy_or_soft_delete_existing_recensement!
          existing_recensement.destroy_or_soft_delete!(
            reason: "changement-de-commune",
            message: "changement de commune appliqué #{commune_before_update} → #{commune_after_update || 'ø'}",
            objet_snapshot: @persisted_objet_snapshot_before_changes
          )
        end

        def log_message
          return nil if action == :not_changed

          @log_message ||= begin
            m = ["mise à jour de l’objet #{palissy_REF} : #{persisted_objet.changes}"]
            case action
            when :update_with_commune_change
              m << commune_change_message
            when :update_with_commune_change_recensement_deleted
              m << commune_change_message
              m << "recensement associé supprimé ou soft-deleted"
            end
            m.join(" - ")
          end
        end
      end
    end
  end
end
