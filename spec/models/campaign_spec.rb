# frozen_string_literal: true

require "rails_helper"

# rubocop: disable Metrics/BlockLength
RSpec.describe Campaign, type: :model do
  describe "factory" do
    it "should be valid" do
      campaign = build(:campaign)
      res = campaign.valid?
      expect(campaign.errors).to be_empty
      expect(res).to eq true
    end
  end

  describe "#step_for_date" do
    let(:campaign) do
      build(
        :campaign,
        date_lancement: Date.new(2030, 5, 10),
        date_relance1: Date.new(2030, 5, 15),
        date_relance2: Date.new(2030, 5, 20),
        date_relance3: Date.new(2030, 5, 25),
        date_fin: Date.new(2030, 5, 30)
      )
    end
    subject { campaign.step_for_date(date) }

    context "date is before lancement" do
      let(:date) { Date.new(2030, 1, 1) }
      it { should eq nil }
    end

    context "date is lancement date" do
      let(:date) { Date.new(2030, 5, 10) }
      it { should eq "lancement" }
    end

    context "date is between lancement and relance1" do
      let(:date) { Date.new(2030, 5, 12) }
      it { should eq "lancement" }
    end

    context "date is relance1" do
      let(:date) { Date.new(2030, 5, 15) }
      it { should eq "relance1" }
    end

    context "date is between relance1 and relance2" do
      let(:date) { Date.new(2030, 5, 17) }
      it { should eq "relance1" }
    end

    context "date is relance2" do
      let(:date) { Date.new(2030, 5, 20) }
      it { should eq "relance2" }
    end

    context "date is between relance3 and end" do
      let(:date) { Date.new(2030, 5, 27) }
      it { should eq "relance3" }
    end

    context "date is date_fin" do
      let(:date) { Date.new(2030, 5, 30) }
      it { should eq "fin" }
    end

    context "date is after date_fin" do
      let(:date) { Date.new(2030, 6, 10) }
      it { should eq "fin" }
    end
  end

  describe "#previous_step_for" do
    subject { Campaign.previous_step_for(step) }

    context "step is lancement" do
      let(:step) { "lancement" }
      it { should eq nil }
    end

    context "step is relance1" do
      let(:step) { "relance1" }
      it { should eq "lancement" }
    end

    context "step is relance3" do
      let(:step) { "relance3" }
      it { should eq "relance2" }
    end

    context "step is end" do
      let(:step) { "fin" }
      it { should eq "relance3" }
    end
  end

  describe "validation coherent dates" do
    let(:date_lancement) { Date.new(2030, 1, 3) }
    let(:date_relance1) { date_lancement + 2.weeks }
    let(:date_relance2) { date_relance1 + 2.weeks }
    let(:date_relance3) { date_relance2 + 2.weeks }
    let(:date_fin) { date_relance3 + 2.weeks }
    let(:campaign) do
      build(:campaign, status: :draft, date_lancement:, date_relance1:, date_relance2:, date_relance3:, date_fin:)
    end
    subject { campaign.valid? }

    context "coherent dates" do
      it { should eq true }
    end

    context "relance2 is before relance1" do
      let(:date_relance2) { date_relance1 - 1.week }
      it { should eq false }
    end

    context "relance2 is same day as relance1" do
      let(:date_relance2) { date_relance1 }
      it { should eq false }
    end

    context "lancement date is in the past" do
      let(:date_lancement) { Time.zone.today.prev_occurring(:monday) }
      it { should eq false }
    end

    context "lancement date is today" do
      let(:date_lancement) { Time.zone.today }
      it { should eq false }
    end

    context "lancement date is in the past for finished campaign" do
      let(:date_lancement) { Time.zone.today.prev_occurring(:monday) }
      let(:campaign) do
        build(
          :campaign,
          status: :finished, date_lancement:, date_relance1:, date_relance2:,
          date_relance3:, date_fin:
        )
      end
      it { should eq true }
    end

    context "begins on a monday" do
      let(:date_lancement) { Date.current.next_week(:monday) }
      it { should eq true }
    end

    context "begins on a saturday" do
      let(:date_lancement) { Date.current.next_week(:saturday) }
      it { should eq false }
    end

    context "begins on a sunday" do
      let(:date_lancement) { Date.current.next_week(:saturday) }
      it { should eq false }
    end
  end

  describe "validate no overlap for planned" do
    let!(:departement) { create(:departement) }
    let!(:existing_campaign) { create(:campaign, departement:, status: :planned, date_lancement: Date.new(2030, 1, 1)) }
    subject { new_campaign.valid? }

    context "new campaign does not overlap" do
      let(:new_campaign) { build(:campaign, departement:, status: :planned, date_lancement: Date.new(2030, 6, 1)) }
      it { should eq false }
    end

    context "new campaign overlaps with other planned one" do
      let(:new_campaign) { build(:campaign, departement:, status: :planned, date_lancement: Date.new(2030, 1, 15)) }
      it { should eq false }
    end

    context "new draft campaign overlaps with other planned one" do
      let(:new_campaign) { build(:campaign, departement:, status: :draft, date_lancement: Date.new(2030, 1, 15)) }
      it { should eq true }
    end
  end

  describe "validate_only_invalid_communes" do
    let!(:campaign) { create(:campaign, status: "draft") }
    let!(:campaign_recipient1) do
      create(:campaign_recipient, campaign:, commune: build(:commune_with_user, status: "inactive"))
    end
    let!(:campaign_recipient2) do
      create(:campaign_recipient, campaign:, commune: build(:commune_with_user, status: "inactive"))
    end

    context "only inactive communes" do
      it "should allow planning the campaign" do
        res = campaign.plan!
        expect(res).to eq true
        expect(campaign.reload.status).to eq("planned")
      end
    end

    context "some active communes" do
      before { campaign_recipient2.commune.start! }

      it "should not allow planning the campaign" do
        expect(campaign.may_plan?).to eq false
        expect { campaign.plan! }.to raise_exception(AASM::InvalidTransition)
        expect(campaign.reload.status).to eq("draft")
      end
    end
  end
end
# rubocop: enable Metrics/BlockLength
