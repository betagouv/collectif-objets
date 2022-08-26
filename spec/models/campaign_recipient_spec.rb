# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe CampaignRecipient, type: :model do
  describe "factory" do
    it "should be valid" do
      recipient = build(:campaign_recipient)
      res = recipient.valid?
      expect(recipient.errors).to be_empty
      expect(res).to eq true
    end

    it "can build 2 recipients for the same campaign" do
      campaign = FactoryBot.create(:campaign)
      recipient = build(:campaign_recipient, campaign:)
      res = recipient.valid?
      expect(recipient.errors).to be_empty
      expect(res).to eq true

      recipient2 = build(:campaign_recipient, campaign:, current_step: "lancement")
      res = recipient2.valid?
      expect(recipient2.errors).to be_empty
      expect(res).to eq true
    end

    describe "validate_inactive" do
      subject { campaign_recipient.valid? }
      context "inactive communes can be added as recipients" do
        let(:campaign_recipient) do
          build(:campaign_recipient, campaign: build(:campaign, status: "draft"),
                                     commune: build(:commune, status: "inactive"))
        end
        it { should eq true }
      end

      context "active communes cannot be added as recipients" do
        let(:campaign_recipient) do
          build(:campaign_recipient, campaign: build(:campaign, status: "draft"),
                                     commune: build(:commune, status: "started"))
        end
        it { should eq false }
      end

      context "active communes can be re-saved as recipients for ongoing campaigns" do
        let!(:campaign) { create(:campaign, status: "draft") }
        let!(:commune) { create(:commune, status: "inactive") }
        let!(:campaign_recipient) { create(:campaign_recipient, campaign:, commune:) }
        before do
          campaign.plan!
          campaign.start!
          commune.start!
        end
        it { should eq true }
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
