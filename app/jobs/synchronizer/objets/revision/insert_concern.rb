# frozen_string_literal: true

module Synchronizer
  module Objets
    module Revision
      module InsertConcern
        extend ActiveSupport::Concern

        def objet
          @objet ||= Objet.new(all_attributes)
        end

        def synchronize
          return false unless objet_valid?

          log "création de l’objet #{palissy_REF} avec #{all_attributes.except(:palissy_REF)}", counter: :create
          objet.save!
          true
        end

        private

        def objet_valid?
          return true if objet.valid?

          log "création de l'objet #{palissy_REF} rejeté car l’objet n'est pas valide " \
              ": #{objet.errors.full_messages.to_sentence} - #{all_attributes}",
              counter: :create_rejected_invalid
          false
        end
      end
    end
  end
end
