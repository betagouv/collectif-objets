# frozen_string_literal: true

module Synchronizer
  module Objets
    module RevisionConcern
      extend ActiveSupport::Concern

      included do
        delegate :changed?, :changes, :palissy_ref, to: :objet_builder

        attr_reader :action

        private

        attr_reader :row, :commune, :logfile, :dry_run
      end

      private

      def log(message)
        return if logfile.nil? || message.blank?

        logfile.puts(message)
        logfile.flush
      end

      def dry_run? = dry_run
    end
  end
end
