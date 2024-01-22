# frozen_string_literal: true

module Synchronizer
  module Edifices
    class SynchronizeAllJob
      include Sidekiq::Job

      def perform
        @progressbar = ProgressBar.create(total: client.count_all, format: "%t: |%B| %p%% %e %c/%u")
        client.each do |row|
          Revision.new(row).synchronize
          @progressbar.increment
        end
      end

      private

      def client
        @client ||= ApiClientMerimee.new
      end
    end
  end
end
