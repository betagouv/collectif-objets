# frozen_string_literal: true

require "rails_helper"

# rubocop: disable Metrics/BlockLength

RSpec.describe Campaigns::RunCampaignJob, type: :job do
  describe "#perform" do
    let!(:campaign) { create(:campaign, status: "ongoing") }

    let!(:recipient1) do
      create(:campaign_recipient, campaign:, commune: build(:commune_with_user, status: "inactive"),
                                  current_step: "lancement")
    end
    let!(:recipient2) do
      create(:campaign_recipient, campaign:, commune: build(:commune_with_user, status: "inactive"), current_step: nil)
    end
    let!(:recipient3) do
      create(:campaign_recipient, campaign:, commune: build(:commune_with_user, status: "inactive"),
                                  current_step: "fin")
    end
    let!(:recipient4) do
      create(:campaign_recipient, campaign:, commune: build(:commune_with_user, status: "inactive"),
                                  current_step: "relance1")
    end
    let!(:recipient5) do
      create(:campaign_recipient, campaign:, commune: build(:commune_with_user, status: "inactive"), current_step: nil)
    end
    let!(:recipient6) do
      create(:campaign_recipient, campaign:, commune: build(:commune_with_user, status: "inactive"),
                                  current_step: "relance1")
    end
    let!(:recipient7) do
      create(:campaign_recipient, campaign:, commune: build(:commune_with_user, status: "inactive"),
                                  current_step: "relance3")
    end
    let!(:recipient8) do
      create(:campaign_recipient, campaign:, commune: build(:commune_with_user, status: "inactive"),
                                  current_step: "fin")
    end
    let!(:recipient9) do
      create(:campaign_recipient, campaign:, commune: build(:commune_with_user, status: "started"), current_step: nil)
    end
    let!(:recipient10) do
      create(
        :campaign_recipient,
        campaign:, commune: build(:commune_with_user), current_step: nil,
        opt_out: true, opt_out_reason: "other"
      )
    end
    let!(:recipient11) do
      create(:campaign_recipient, campaign:, commune: build(:commune_with_user, status: "completed"), current_step: nil)
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
        expect(Campaigns::StepUpRecipientJob).to receive(:perform_async)
          .with(recipient9.id, "lancement") # started do receive mails
        expect(Campaigns::StepUpRecipientJob).not_to receive(:perform_async)
          .with(recipient10.id, "lancement") # opted out
        expect(Campaigns::StepUpRecipientJob).not_to receive(:perform_async)
          .with(recipient11.id, "lancement") # but completed do not
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
