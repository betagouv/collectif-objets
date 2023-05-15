# frozen_string_literal: true

module Synchronizer
  class SynchronizeObjetsJob
    include Sidekiq::Job

    def initialize
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

    attr_reader :interactive, :logfile

    def synchronize_rows(rows)
      batch = ObjetRevisionsBatch.from_rows(rows, revision_kwargs: { interactive:, logfile: })
      batch.revisions_by_action.each do |action, revisions|
        @counters[action] += revisions.count
        revisions.each(&:synchronize)
      end
    end

    def close
      @logfile.puts "counters: #{@counters}"
      @logfile.close
    end

    def timestamp
      Time.zone.now.strftime("%Y_%m_%d_%HH%M")
    end
  end
end
