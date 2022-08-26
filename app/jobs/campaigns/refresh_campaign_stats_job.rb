# frozen_string_literal: true

module Campaigns
  class RefreshCampaignStatsJob
    include Sidekiq::Job

    def perform(campaign_id)
      @campaign = Campaign.find(campaign_id)
      @campaign.update!(stats: Campaigns::ComputeCampaignStatsService.new(@campaign).perform)
    end
  end
end
