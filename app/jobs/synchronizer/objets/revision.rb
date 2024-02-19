# frozen_string_literal: true

module Synchronizer
  module Objets
    class Revision
      include RevisionEdificeConcern
      include LogConcern

      def initialize(objet_attributes, eager_loaded_records:, logger: nil)
        @objet_attributes = objet_attributes
        @eager_loaded_records = eager_loaded_records
        @logger = logger
        @persisted_objet = @eager_loaded_records.objet
        if persisted_objet
          @commune_before_update = persisted_objet.commune
          extend RevisionUpdateConcern
        else
          extend RevisionInsertConcern
        end
      end

      def synchronize
        return false if @objet_attributes[:lieu_actuel_code_insee].blank?

        return false unless check_objet_valid

        log log_message, counter: action
        objet.save! if action != :not_changed
        true
      end

      private

      attr_reader :row, :objet_attributes, :persisted_objet, :commune_before_update

      def commune = @eager_loaded_records.commune
      alias commune_after_update commune

      def palissy_REF = objet_attributes[:palissy_REF]

      def all_attributes
        objet_attributes.merge(edifice_attributes)
      end

      def check_objet_valid
        return true if objet.valid?

        log "#{create_or_update} de l'objet #{palissy_REF} rejeté car l’objet n'est pas valide " \
            ": #{objet.errors.full_messages.to_sentence} - #{all_attributes}",
            counter: :"#{create_or_update}_rejected_invalid"
        false
      end
    end
  end
end
