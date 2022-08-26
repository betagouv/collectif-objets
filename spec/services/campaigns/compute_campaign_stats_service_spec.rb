# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength

RSpec.describe Campaigns::ComputeCampaignStatsService, type: :service do
  subject { Campaigns::ComputeCampaignStatsService.new(campaign).perform }

  context "some various state" do
    let!(:campaign) { create(:campaign) }
    let!(:campaign_recipient1) { create(:campaign_recipient, campaign:) }
    let!(:campaign_recipient2) { create(:campaign_recipient, campaign:) }
    let!(:campaign_recipient3) { create(:campaign_recipient, campaign:) }
    let!(:campaign_email_lancement1) do
      create(:campaign_email, step: "lancement", recipient: campaign_recipient1, sent: true)
    end
    let!(:campaign_email_lancement2) do
      create(:campaign_email, step: "lancement", recipient: campaign_recipient2, sent: true, delivered: true)
    end
    let!(:campaign_email_lancement3) do
      create(
        :campaign_email,
        step: "lancement", recipient: campaign_recipient3, sent: true, error: true, error_reason: "whatever"
      )
    end
    let!(:campaign_email_rappel1) do
      create(:campaign_email, step: "reminder", recipient: campaign_recipient1, sent: true, delivered: true,
                              opened: true)
    end
    let!(:campaign_email_rappel2) do
      create(:campaign_email, step: "reminder", recipient: campaign_recipient2, sent: true, delivered: true)
    end
    let!(:campaign_email_rappel3) { create(:campaign_email, step: "reminder", recipient: campaign_recipient3) }

    it "should work" do
      stats = subject
      expect(stats[:mails][:all][:count]).to eq(6)

      expect(stats[:mails][:all][:error][:count]).to eq(1)
      expect(stats[:mails][:all][:error][:count_exclusive]).to eq(1)
      expect(stats[:mails][:all][:error][:ratio]).to be_within(0.001).of(1.0 / 6)

      expect(stats[:mails][:all][:pending][:count_exclusive]).to eq(1)
      # expect(stats[:mails][:all][:pending][:ratio]).to be_within(0.001).of(1.0 / 6)

      expect(stats[:mails][:all][:sent][:count]).to eq(4)
      expect(stats[:mails][:all][:sent][:count_exclusive]).to eq(1)
      expect(stats[:mails][:all][:sent][:ratio]).to be_within(0.001).of(4.0 / 6)

      expect(stats[:mails][:all][:delivered][:count]).to eq(3)
      expect(stats[:mails][:all][:delivered][:count_exclusive]).to eq(2)
      expect(stats[:mails][:all][:delivered][:ratio]).to be_within(0.001).of(3.0 / 6)

      expect(stats[:mails][:all][:opened][:count]).to eq(1)
      expect(stats[:mails][:all][:opened][:count_exclusive]).to eq(1)
      expect(stats[:mails][:all][:opened][:ratio]).to be_within(0.001).of(1.0 / 6)

      expect(stats[:mails][:all][:clicked][:count]).to eq(0)
      expect(stats[:mails][:all][:clicked][:count_exclusive]).to eq(0)
      expect(stats[:mails][:all][:clicked][:ratio]).to be_within(0.001).of(0.0 / 6)
    end
  end
end

# rubocop:enable Metrics/BlockLength
