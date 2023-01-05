# frozen_string_literal: true

require "rails_helper"

describe Conservateurs::CampaignRecipientPolicy do
  subject { described_class }

  permissions :show? do
    context "departement du conservateur" do
      let(:departements) { build_list(:departement, 3) }
      let(:campaign) { build(:campaign, departement: departements[1]) }
      let(:campaign_recipient) { build(:campaign_recipient, campaign:, departement: departements[1]) }
      let(:conservateur) { build(:conservateur, departements:) }
      it { should permit(conservateur, campaign_recipient) }
    end

    context "autre departement" do
      let(:departements) { build_list(:departement, 3) }
      let(:campaign) { build(:campaign, departement: departements[1]) }
      let(:campaign_recipient) { build(:campaign_recipient, campaign:, departement: build(:departement)) }
      let(:conservateur) { build(:conservateur, departements:) }
      it { should_not permit(conservateur, campaign_recipient) }
    end
  end
end
