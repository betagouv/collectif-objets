# frozen_string_literal: true

module Campaigns
  class RefreshCampaignStatsJob < ApplicationJob
    def perform(campaign_id)
      @campaign = Campaign.find(campaign_id)
      @campaign.refresh_stats
    end
  end
end
