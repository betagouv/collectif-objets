# frozen_string_literal: true

require "rails_helper"

# rubocop: disable Metrics/BlockLength

RSpec.describe Campaigns::RunCampaignJob, type: :job do
  describe "#perform" do
    let!(:campaign) { create(:campaign, status: "ongoing") }

    let!(:recipient1) { create(:campaign_recipient, campaign:, commune: build(:commune), current_step: "lancement") }
    let!(:recipient2) { create(:campaign_recipient, campaign:, commune: build(:commune), current_step: nil) }
    let!(:recipient3) { create(:campaign_recipient, campaign:, commune: build(:commune), current_step: "fin") }
    let!(:recipient4) { create(:campaign_recipient, campaign:, commune: build(:commune), current_step: "relance1") }
    let!(:recipient5) { create(:campaign_recipient, campaign:, commune: build(:commune), current_step: nil) }
    let!(:recipient6) { create(:campaign_recipient, campaign:, commune: build(:commune), current_step: "relance1") }
    let!(:recipient7) { create(:campaign_recipient, campaign:, commune: build(:commune), current_step: "relance3") }
    let!(:recipient8) { create(:campaign_recipient, campaign:, commune: build(:commune), current_step: "fin") }
    let!(:recipient10) do
      create(
        :campaign_recipient,
        campaign:, commune: build(:commune), current_step: nil,
        opt_out: true, opt_out_reason: "other"
      )
    end

    before do
      expect(Campaign).to receive(:find).with(campaign.id).and_return(campaign)
      expect(campaign).to receive(:current_step).at_least(:once).and_return(current_step)
    end

    context "campaign is beginning" do
      let(:current_step) { "lancement" }

      it "should return recipients that have not yet begun" do
        expect(Campaigns::StepUpRecipientJob).not_to receive(:perform_async).with(recipient1.id, "lancement")
        expect(Campaigns::StepUpRecipientJob).to receive(:perform_async).with(recipient2.id, "lancement")
        expect(Campaigns::StepUpRecipientJob).to receive(:perform_async).with(recipient5.id, "lancement")
        expect(Campaigns::StepUpRecipientJob).not_to receive(:perform_async).with(recipient10.id, "lancement")
        # opted out
        Campaigns::RunCampaignJob.new.perform(campaign.id)
      end
    end

    context "campaign is in relance2" do
      let(:current_step) { "relance2" }

      it "should return recipients in relance1" do
        expect(Campaigns::StepUpRecipientJob).not_to receive(:perform_async).with(recipient1.id, "relance2")
        expect(Campaigns::StepUpRecipientJob).to receive(:perform_async).with(recipient4.id, "relance2")
        expect(Campaigns::StepUpRecipientJob).to receive(:perform_async).with(recipient6.id, "relance2")
        Campaigns::RunCampaignJob.new.perform(campaign.id)
      end
    end

    context "campaign is ending" do
      let(:current_step) { "fin" }

      it "should return recipients that are in relance3" do
        expect(Campaigns::StepUpRecipientJob).not_to receive(:perform_async).with(recipient1.id, "fin")
        expect(Campaigns::StepUpRecipientJob).to receive(:perform_async).with(recipient7.id, "fin")
        Campaigns::RunCampaignJob.new.perform(campaign.id)
      end
    end
  end
end

# rubocop: enable Metrics/BlockLength
