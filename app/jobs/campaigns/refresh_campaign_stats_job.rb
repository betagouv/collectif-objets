# frozen_string_literal: true

module Campaigns
  class RefreshCampaignStatsJob < ApplicationJob
    def perform(campaign_id)
      @campaign = Campaign.find(campaign_id)
      @campaign.update_columns(stats: CampaignStats.new(@campaign).stats)
    end
  end
end
