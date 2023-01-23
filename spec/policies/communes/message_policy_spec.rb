# frozen_string_literal: true

require "rails_helper"

describe Communes::MessagePolicy do
  subject { described_class }

  permissions :create? do
    context "message de la commune du user" do
      let(:commune) { build(:commune, status: :inactive) }
      let(:message) { build(:message, commune:) }
      let(:user) { build(:user, commune:) }

      it { should permit(user, message) }
    end

    context "message d'une autre commune" do
      let(:commune1) { build(:commune, status: :inactive) }
      let(:commune2) { build(:commune, status: :inactive) }
      let(:message) { build(:message, commune: commune1) }
      let(:user) { build(:user, commune: commune2) }

      it { should_not permit(user, message) }
    end
  end
end

describe Communes::MessagePolicy::Scope do
  context "4 messages de differentes communes" do
    let!(:commune1) { create(:commune, status: :inactive) }
    let!(:commune2) { create(:commune, status: :inactive) }
    let!(:messages1) { create_list(:message, 2, commune: commune1) }
    let!(:messages2) { create_list(:message, 2, commune: commune2) }
    let!(:user1) { create(:user, commune: commune1) }
    let!(:user2) { create(:user, commune: commune2) }

    it "renvoie les messages de la commune du user" do
      messages = described_class.new(user1, Message.all).resolve
      expect(messages.count).to eq 2
      expect(messages).to include messages1[0]
      expect(messages).to include messages1[1]
      expect(messages).not_to include messages2[0]
      expect(messages).not_to include messages2[1]
    end
  end
end
