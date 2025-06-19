# frozen_string_literal: true

module Synchronizer
  module Edifices
    class SynchronizeAllJob < ApplicationJob
      BATCH_SIZE = 1000

      def perform
        @progressbar = ProgressBar.create(total: client.count_all, format: "%t: |%B| %p%% %e %c/%u")
        client.each_slice(BATCH_SIZE) do |csv_rows|
          batch = Synchronizer::Edifices::Batch::Base.new(csv_rows, logger:)
          batch.synchronize { @progressbar.increment }
        end
        logger.close
        client.remove_temp_file!
      end

      private

      def client
        @client ||= ApiClientMerimee.new
      end

      def logger
        @logger ||= Synchronizer::Logger.new(filename_prefix: "synchronize-edifices")
      end
    end
  end
end
