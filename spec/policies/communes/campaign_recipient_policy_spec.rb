# frozen_string_literal: true

require "rails_helper"

describe Communes::CampaignRecipientPolicy do
  subject { described_class }

  permissions :update? do
    context "commune du user" do
      let(:user) { build(:user) }
      let(:campaign_recipient) { build(:campaign_recipient, commune: user.commune) }
      it { should permit(user, campaign_recipient) }
    end

    context "autre commune" do
      let(:user) { build(:user) }
      let(:campaign_recipient) { build(:campaign_recipient, commune: build(:commune)) }
      it { should_not permit(user, campaign_recipient) }
    end
  end
end
