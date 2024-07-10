# frozen_string_literal: true

require "rails_helper"

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
                                     commune: build(:commune_with_user, status: "inactive"))
        end
        it { should eq true }
      end

      context "active communes cannot be added as recipients" do
        let(:campaign_recipient) do
          build(:campaign_recipient, campaign: build(:campaign, status: "draft"),
                                     commune: build(:commune_with_user, status: "started"))
        end
        it { should eq false }
      end

      context "active communes can be re-saved as recipients for ongoing campaigns" do
        let!(:campaign) { create(:campaign, status: "draft") }
        let!(:commune) { create(:commune_with_user, status: "inactive") }
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

  describe "should_skip_mail_for_step" do
    subject { recipient.should_skip_mail_for_step(step) }

    context "première relance pour une commune ayant démarré le recensement" do
      let(:step) { "relance1" }
      let!(:commune) { create(:commune_with_user, status: "started") }
      let!(:campaign) { create(:campaign) }
      let!(:recipient) { create(:campaign_recipient, campaign:, commune:, current_step: "lancement") }

      it { should eq true }
    end

    context "première relance pour une commune n'ayant pas démarré le recensement" do
      let(:step) { "relance1" }
      let!(:commune) { create(:commune_with_user, status: "inactive") }
      let!(:campaign) { create(:campaign) }
      let!(:recipient) { create(:campaign_recipient, campaign:, commune:, current_step: "lancement") }

      it { should eq false }
    end

    context "seconde relance pour une commune ayant recensé juste avant" do
      let(:step) { "relance2" }
      let!(:commune) { create(:commune_en_cours_de_recensement) }
      let!(:campaign) { create(:campaign) }
      let!(:objet) { create(:objet, commune:) }
      let!(:recensement) do
        create(:recensement, objet:, dossier: commune.dossier, updated_at: campaign.date_relance2 - 1.day)
      end
      let!(:recipient) { create(:campaign_recipient, campaign:, commune:, current_step: "relance1") }

      it { should eq true }
    end

    context "seconde relance pour une commune ayant recensé il y a plus de 5 jours" do
      let(:step) { "relance2" }
      let!(:commune) { create(:commune, :with_user, :en_cours_de_recensement) }
      let!(:campaign) { create(:campaign) }
      let!(:objet) { create(:objet, commune:) }
      let!(:recensement) do
        create(:recensement, objet:, dossier: commune.dossier, updated_at: campaign.date_relance2 - 10.days)
      end
      let!(:recipient) { create(:campaign_recipient, campaign:, commune:, current_step: "relance1") }

      it { should eq false }
    end
  end
end
