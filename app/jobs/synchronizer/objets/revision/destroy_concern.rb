# frozen_string_literal: true

module Synchronizer
  module Objets
    module Revision
      module DestroyConcern
        extend ActiveSupport::Concern

        def synchronize
          log log_message, counter: action
          persisted_objet.destroy_and_soft_delete_recensement!(
            reason: "objet-devenu-hors-scope",
            message: soft_delete_message,
            objet_snapshot: @persisted_objet_snapshot_before_changes
          )
          true
        end

        # TODO: Revision#new_edifice? should default to false, this is a code smell
        def new_edifice? = false

        private

        def soft_delete_message = row.out_of_scope_message

        def action
          if existing_recensement
            :destroy_with_recensement
          else
            :destroy
          end
        end

        def existing_recensement
          @existing_recensement ||= persisted_objet.recensements.first
        end

        def log_message
          @log_message ||= begin
            m = ["suppression de l’objet #{palissy_REF} qui est passé hors-scope"]
            m << soft_delete_message
            m << objet_attributes.to_s
            if action == :destroy_with_recensement
              m << "soft delete du recensement associé #{existing_recensement.attributes}"
            end
            m.join(" - ")
          end
        end
      end
    end
  end
end
