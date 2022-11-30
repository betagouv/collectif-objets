# frozen_string_literal: true

module Synchronizer
  class SynchronizeEdificesJob
    include Sidekiq::Job

    def perform(params = {})
      limit = params.with_indifferent_access[:limit]
      @dry_run = params.with_indifferent_access[:dry_run]
      ApiClientSql
        .edifices(logger:, limit:)
        .iterate { EdificeRow.new(_1).synchronize }
    end
  end
end
