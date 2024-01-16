# frozen_string_literal: true

module Synchronizer
  module Objets
    class SynchronizeAllJob
      include Sidekiq::Job

      def initialize
        @counters = Hash.new(0)
      end

      def perform(params = {})
        @logfile = File.open("tmp/synchronize-objets-#{timestamp}.log", "a+")
        limit = params.with_indifferent_access[:limit]
        @dry_run = params.with_indifferent_access[:dry_run]
        code_insee = params.with_indifferent_access[:code_insee]
        ApiClientSql.objets(logger:, limit:, code_insee:).iterate_batches { synchronize_rows(_1) }
        close
      end

      private

      attr_reader :logfile, :dry_run

      def synchronize_rows(rows)
        RevisionsBatch
          .new(rows, revision_kwargs: { logfile:, dry_run: })
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
end
