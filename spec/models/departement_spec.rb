# frozen_string_literal: true

require "rails_helper"

describe Departement, type: :model do
  describe "#parse_from_code_insee" do
    subject { Departement.parse_from_code_insee(code_insee) }
    context "Paris" do
      let(:code_insee) { "75056" }
      it { is_expected.to eq "75" }
    end

    context "martinique - fort de france" do
      let(:code_insee) { "97209" }
      it { is_expected.to eq "972" }
    end

    context "09 - Ariège" do
      let(:code_insee) { "09001" }
      it { is_expected.to eq "09" }
    end

    context "ajaccio" do
      let(:code_insee) { "2A004" }
      it { is_expected.to eq "2A" }
    end

    context "nil" do
      let(:code_insee) { nil }
      it { is_expected.to eq nil }
    end
  end

  describe "#activity" do
    let(:departement) { create(:departement) }
    let(:commune) { create(:commune, :with_user, departement:) }
    let(:commune2) { create(:commune, :with_user, departement:) }
    let(:commune_autre_departement) { create(:commune, :with_user) }
    let(:date_range) { Time.zone.now.all_week }
    subject(:activity) { departement.activity(date_range) }

    context "quand des communes ont écrit des messages" do
      it "liste les messages" do
        # Message trop ancien
        create(:message, commune:, author: commune.users.first, created_at: date_range.first - 1.day,
                         text: "Trop ancien")
        # Message d'une commune hors département
        create(:message, commune: commune_autre_departement, author: commune_autre_departement.users.first,
                         created_at: date_range.first + 1.day, text: "Hors département")
        # Messages attendus
        expected_messages = [
          create(:message, commune:, author: commune.users.first,  created_at: date_range.first + 1.hour,
                           text: "Reçu en début de période"),
          create(:message, commune:, author: commune2.users.first, created_at: date_range.last - 1.hour,
                           text: "Reçu en fin de période")
        ]
        expect(activity.key?(:new_messages)).to eq true
        expect(activity[:new_messages]).to eq expected_messages
      end
    end
  end
end
