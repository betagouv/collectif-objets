# frozen_string_literal: true

module Campaigns
  class RunCampaignJob < ApplicationJob
    def perform(campaign_id)
      @campaign = Campaign.find(campaign_id)
      return unless @campaign.ongoing?

      recipients_to_step_up.each do |recipient|
        Campaigns::StepUpRecipientJob.perform_later(recipient.id, current_step)
      end
    end

    private

    attr_reader :campaign

    delegate :current_step, :previous_step, to: :campaign

    def recipients_to_step_up
      @campaign.recipients.joins(:commune)
        .where(current_step: previous_step)
        .where(opt_out: [nil, false])
        .where.not(communes: { status: "completed" })
    end
  end
end
