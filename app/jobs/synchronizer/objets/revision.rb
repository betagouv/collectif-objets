# frozen_string_literal: true

module Synchronizer
  module Objets
    class Revision
      include RevisionEdificeConcern

      attr_reader :action, :objet_attributes

      def initialize(objet_attributes, eager_loaded_records:, logfile: nil)
        @objet_attributes = objet_attributes
        @eager_loaded_records = eager_loaded_records
        @logfile = logfile
        @persisted_objet = @eager_loaded_records.objet
        if persisted_objet
          @commune_before_update = persisted_objet.commune
          extend RevisionUpdateConcern
        else
          extend RevisionInsertConcern
        end
      end

      def synchronize
        return false if !check_objet_valid || !check_changed

        set_action_and_log
        objet.save!
        true
      end

      private

      attr_reader :logfile, :persisted_objet, :commune_before_update

      def commune = @eager_loaded_records.commune
      alias commune_after_update commune

      def palissy_REF = objet_attributes[:palissy_REF]

      def all_attributes
        objet_attributes.merge(edifice_attributes)
      end

      def check_objet_valid
        return true if objet.valid?

        @action = :"#{create_or_update}_rejected_invalid"
        log "#{create_or_update} de l'objet #{palissy_REF} rejeté car l’objet n'est pas valide " \
            ": #{objet.errors.full_messages.to_sentence} - #{all_attributes}"
        false
      end

      def check_changed
        return true if objet.changed?

        @action = :not_changed
        false
      end

      def log(message)
        return if logfile.nil? || message.blank?

        logfile.puts(message)
        logfile.flush
      end
    end
  end
end
