# frozen_string_literal: true

module Campaigns
  class SynchronizeCampaignEmailsJob
    include Sidekiq::Job
    sidekiq_options retry: 0

    def perform(campaign_id)
      @campaign = Campaign.find(campaign_id)

      return if @campaign.imported?

      @campaign.emails.each { Campaigns::SynchronizeEmailJob.perform_async(_1.id) }
    end
  end
end
