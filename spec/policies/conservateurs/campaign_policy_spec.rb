# frozen_string_literal: true

require "rails_helper"

describe Conservateurs::CampaignPolicy do
  subject { described_class }

  permissions :show? do
    context "departement du conservateur" do
      let(:departements) { build_list(:departement, 3) }
      let(:campaign1) { build(:campaign, departement: departements[1]) }
      let(:conservateur) { build(:conservateur, departements:) }
      it { should permit(conservateur, campaign1) }
    end

    context "autre departement" do
      let(:departements) { build_list(:departement, 3) }
      let(:campaign) { build(:campaign, departement: build(:departement)) }
      let(:conservateur) { build(:conservateur, departements:) }
      it { should_not permit(conservateur, campaign) }
    end
  end
end

describe Conservateurs::CampaignPolicy::Scope do
  context "quelques departements" do
    let!(:departements1) { create_list(:departement, 2) }
    let!(:campaigns1a) { create_list(:campaign, 2, departement: departements1[0]) }
    let!(:campaigns1b) { create_list(:campaign, 2, departement: departements1[1]) }
    let!(:departements2) { create_list(:departement, 2) }
    let!(:campaigns2a) { create_list(:campaign, 2, departement: departements2[0]) }
    let!(:campaigns2b) { create_list(:campaign, 2, departement: departements2[1]) }
    let!(:conservateur) { create(:conservateur, departements: departements1) }

    it "renvoie les campagnes des departements du conservateur" do
      campaigns = described_class.new(conservateur, Campaign).resolve
      expect(campaigns.count).to eq 4
      expect(campaigns).to include campaigns1a[0]
      expect(campaigns).to include campaigns1a[1]
      expect(campaigns).to include campaigns1b[0]
      expect(campaigns).to include campaigns1b[1]
      expect(campaigns).not_to include campaigns2a[0]
      expect(campaigns).not_to include campaigns2a[1]
      expect(campaigns).not_to include campaigns2b[0]
      expect(campaigns).not_to include campaigns2b[1]
    end
  end
end
