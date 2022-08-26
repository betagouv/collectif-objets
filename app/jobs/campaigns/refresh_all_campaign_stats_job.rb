# frozen_string_literal: true

module Campaigns
  class RefreshAllCampaignStatsJob
    include Sidekiq::Job

    def perform
      Campaign.ongoing.or(finished_campaigns).select(:id).each do |campaign|
        Campaigns::RefreshCampaignStatsJob.perform_async(campaign.id)
      end
    end

    def finished_campaigns
      Campaign.finished.where("date_fin > ?", 2.weeks.ago)
    end
  end
end
