# frozen_string_literal: true

module Synchronizer
  module Edifices
    class SynchronizeOneJob
      include Sidekiq::Job

      def perform(params = {})
        @params = params
        raise ArgumentError, "missing ref param" if params_i[:ref].blank?

        return Revision.new(row).synchronize if row

        logger.warn "l'API n'a pas renvoyé d'édifices pour la REF '#{params_i[:ref]}'"
      end

      private

      def row
        @row ||= ApiClientMerimee.new.find_by_reference(params_i[:ref]) # rubocop:disable Rails/DynamicFindBy
      end

      def params_i
        @params_i ||= @params.with_indifferent_access
      end
    end
  end
end
