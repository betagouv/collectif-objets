# frozen_string_literal: true

module Campaigns
  class SynchronizeOutdatedEmailsJob
    include Sidekiq::Job
    sidekiq_options retry: 0

    def perform
      CampaignEmail
        .outdated_synchronization
        .each { Campaigns::SynchronizeEmailJob.perform_async(_1.id) }
    end
  end
end
