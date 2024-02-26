# frozen_string_literal: true

module Synchronizer
  module Edifices
    class SynchronizeAllJob < ApplicationJob
      include EnqueueNextJobConcern

      def perform(enqueue_next_job_after_success: false)
        @progressbar = ProgressBar.create(total: client.count_all, format: "%t: |%B| %p%% %e %c/%u")
        client.each do |row|
          Revision.new(row).synchronize
          @progressbar.increment
        end
        enqueue_next_job if enqueue_next_job_after_success
      end

      private

      def client
        @client ||= ApiClientMerimee.new
      end
    end
  end
end
