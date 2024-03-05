# frozen_string_literal: true

module Synchronizer
  module Objets
    class SynchronizeAllJob < ApplicationJob
      BATCH_SIZE = 1000

      def perform
        @progressbar = ProgressBar.create(total: client.count_all, format: "%t: |%B| %p%% %e %c/%u")
        client.each_slice(BATCH_SIZE) { synchronize_batch(_1) }
        logger.close
      end

      private

      def synchronize_batch(csv_rows)
        batch = Synchronizer::Objets::Batch::Base.new(csv_rows, logger:)
        batch.synchronize_each_revision { @progressbar.increment }
        batch.skipped_rows_count.times { @progressbar.increment }
      end

      def logger
        @logger ||= Synchronizer::Logger.new(filename_prefix: "synchronize-objets")
      end

      def client
        @client ||= ApiClientPalissy.new
      end
    end
  end
end
