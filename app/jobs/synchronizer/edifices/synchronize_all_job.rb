# frozen_string_literal: true

module Synchronizer
  module Edifices
    class SynchronizeAllJob
      include Sidekiq::Job

      def perform
        ApiClientMerimee.new.each { Revision.new(_1).synchronize }
      end
    end
  end
end
