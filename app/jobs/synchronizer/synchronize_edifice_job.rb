# frozen_string_literal: true

module Synchronizer
  class SynchronizeEdificeJob < ApplicationJob
    def perform(params = {})
      @params = params
      raise ArgumentError, "missing ref param" if params_i[:ref].blank?

      @dry_run = params_i[:dry_run]

      return EdificeRow.new(row).synchronize if row

      logger.warn "l'API n'a pas renvoyé d'édifices pour la REF '#{params_i[:ref]}'"
    end

    private

    def row
      @row ||=
        ApiClientJson
          .edifices(params: { REF__exact: params_i[:ref] }, logger:, limit: params_i[:limit])
          .first
    end

    def params_i
      @params_i ||= @params.with_indifferent_access
    end
  end
end
