# frozen_string_literal: true

module Synchronizer
  module Objets
    class SynchronizeAllJob < ApplicationJob
      BATCH_SIZE = 1000

      def initialize
        super
        @counters = Hash.new(0)
      end

      def perform
        @logfile = File.open("tmp/synchronize-objets-#{timestamp}.log", "a+")
        @progressbar = ProgressBar.create(total: client.count_all, format: "%t: |%B| %p%% %e %c/%u")
        client.each_slice(BATCH_SIZE) { synchronize_batch(_1) }
        close
      end

      private

      attr_reader :logfile

      def synchronize_batch(csv_rows)
        batch = Batch::Base.new(csv_rows, logfile:)
        batch.synchronize_each_revision do |revision|
          @counters[revision.action] += 1
          @progressbar.increment
        end
        batch.skipped_rows_count.times { @progressbar.increment }
      end

      def close
        @logfile.puts "counters: #{@counters}"
        @logfile.close
      end

      def timestamp = Time.zone.now.strftime("%Y_%m_%d_%HH%M")

      def client
        @client ||= ApiClientPalissy.new
      end
    end
  end
end
