# frozen_string_literal: true

module Synchronizer
  module ObjetRevisionConcern
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Validations
      delegate :changed?, to: :objet

      private

      attr_reader :row, :commune, :logfile, :interactive, :dry_run
    end

    private

    def validate_objet
      return true if objet.valid?

      @errors.add(:base, "l'objet n'est pas valide : ")
    end

    def validate_tico_en_cours
      return true if objet.palissy_TICO != "Traitement en cours"

      @errors.add(:base, "l'objet est en cours de traitement par POP")
    end

    def log(message)
      return if logfile.nil? || message.blank?

      logfile.puts(message)
      logfile.flush
    end

    # rubocop:disable Rails/Output
    def interactive_validation?
      return false unless interactive?

      @interactive_validation ||= begin
        puts "\n----\n#{log_message}\n----"
        response = nil
        while response.nil?
          puts "voulez-vous forcer la sauvegarde de cet objet ? 'oui' : 'non'"
          raw = gets.chomp
          response = false if raw == "non"
          response = true if raw == "oui"
        end
        response
      end
    end
    # rubocop:enable Rails/Output

    def ref = objet.palissy_REF
    def errors_s = errors.full_messages.to_sentence
    def objet_attributes_s = objet.attributes.except("palissy_REF").compact
    def interactive? = interactive
    def dry_run? = interactive
  end
end
