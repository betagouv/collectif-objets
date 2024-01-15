# frozen_string_literal: true

module Synchronizer
  module Objets
    module RevisionConcern
      extend ActiveSupport::Concern

      included do
        delegate :changed?, :changes, :palissy_ref, to: :objet_builder

        attr_reader :action

        private

        attr_reader :row, :commune, :logfile, :interactive, :dry_run
      end

      private

      def log(message)
        return if logfile.nil? || message.blank?

        logfile.puts(message)
        logfile.flush
      end

      # rubocop:disable Rails/Output
      def interactive_validation?
        return false unless interactive?

        @interactive_validation ||= begin
          puts "\n----\n#{row}\n----"
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

      def interactive? = interactive
      def dry_run? = dry_run
    end
  end
end
