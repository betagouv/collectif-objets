# frozen_string_literal: true

module Campaigns
  class RunCampaignJob < ApplicationJob
    def perform(campaign_id)
      @campaign = Campaign.find(campaign_id)
      return unless @campaign.ongoing?

      recipients_to_step_up.each do |recipient|
        Campaigns::StepUpRecipientJob.perform_later(recipient.id, @campaign.current_step)
      end
    end

    private

    attr_reader :campaign

    def recipients_to_step_up
      @campaign.recipients.joins(:commune)
        .where(current_step: @campaign.previous_step)
        .where(opt_out: [nil, false])
        .where.not(communes: { status: "completed" })
    end
  end
end
