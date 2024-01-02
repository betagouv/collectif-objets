# frozen_string_literal: true

module Synchronizer
  class SynchronizeObjetsJob < ApplicationJob
    def initialize
      super
      @counters = Hash.new(0)
    end

    def perform(params = {})
      @logfile = File.open("tmp/synchronize-objets-#{timestamp}.log", "a+")
      limit = params.with_indifferent_access[:limit]
      @dry_run = params.with_indifferent_access[:dry_run]
      @interactive = params.with_indifferent_access[:interactive] || false
      code_insee = params.with_indifferent_access[:code_insee]
      ApiClientSql.objets(logger:, limit:, code_insee:).iterate_batches { synchronize_rows(_1) }
      close
    end

    private

    attr_reader :interactive, :logfile, :dry_run

    def synchronize_rows(rows)
      ObjetRevisionsBatch
        .new(rows, revision_kwargs: { interactive:, logfile:, dry_run: })
        .revisions
        .each do |revision|
          revision.synchronize
          @counters[revision.action] += 1
        end
    end

    def close
      @logfile.puts "counters: #{@counters}"
      @logfile.close
    end

    def timestamp = Time.zone.now.strftime("%Y_%m_%d_%HH%M")
  end
end
