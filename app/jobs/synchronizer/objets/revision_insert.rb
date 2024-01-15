# frozen_string_literal: true

module Synchronizer
  module Objets
    class RevisionInsert
      include RevisionConcern

      def initialize(row, commune:, interactive: false, logfile: nil, dry_run: false)
        @row = row
        @commune = commune
        @interactive = interactive
        @logfile = logfile
        @dry_run = dry_run
      end

      def synchronize
        return false unless check_objet_valid

        objet.save! unless dry_run?
        @action = :create
        log "création de l’objet #{palissy_ref} avec #{objet_builder.attributes.except('palissy_REF')}"
        true
      end

      def objet
        @objet ||= Objet.new(objet_builder.attributes)
      end

      private

      def check_objet_valid
        return true if objet.valid?

        @action = :create_rejected_invalid
        log "création de l'objet #{palissy_ref} rejetée car l’objet n'est pas valide " \
            ": #{objet.errors.full_messages.to_sentence}"
        false
      end

      def objet_builder
        @objet_builder ||= Synchronizer::Objets::Builder.new(row)
      end
    end
  end
end
