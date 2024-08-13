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

  describe "#commune_messages_count(date_range)" do
    let(:departement) { create(:departement) }
    let(:commune) { create(:commune, :with_user, departement:) }
    let(:commune2) { create(:commune, :with_user, departement:) }
    let(:commune_autre_departement) { create(:commune, :with_user) }
    let(:date_range) { Time.zone.now.all_week }
    subject(:commune_messages_count) { departement.commune_messages_count(date_range) }

    context "quand des communes ont écrit des messages" do
      it "indique le nombre de messages par nom de commune" do
        # Message trop ancien
        create(:message, commune:, author: commune.users.first, created_at: date_range.first - 1.day)
        # Message d'une commune hors département
        create(:message, commune: commune_autre_departement, author: commune_autre_departement.users.first,
                         created_at: date_range.first + 1.day)
        # Messages attendus
        create(:message, commune:, author: commune.users.first, created_at: date_range.first + 1.hour)
        create(:message, commune: commune2, author: commune2.users.first, created_at: date_range.last - 1.hour)
        expect(commune_messages_count).to eq({ commune => 1, commune2 => 1 })
      end
    end
  end

  describe "#commune_dossiers_transmis(date_range)" do
    let(:departement) { create(:departement) }
    let(:commune) { create(:commune, :with_user, departement:) }
    let(:commune2) { create(:commune, :with_user, departement:) }
    let(:commune3) { create(:commune, :with_user) }
    let(:date_range) { Time.zone.now.all_week }
    let(:dossier) { create(:dossier, :submitted, :with_recensement, commune:, submitted_at: date_range.first + 1.day) }
    subject(:commune_dossiers_transmis) { departement.commune_dossiers_transmis(date_range) }

    context "quand des communes ont transmis des dossiers" do
      it "liste les communes" do
        create(:dossier, :submitted, :with_recensement, commune:, submitted_at: date_range.first + 1.day)
        create(:dossier, :submitted, :with_recensement, commune: commune2, submitted_at: date_range.first - 1.day)
        create(:dossier, :submitted, :with_recensement, commune: commune3, submitted_at: date_range.first + 1.day)
        expect(commune_dossiers_transmis).to eq [commune]
      end
      context "avec des objets disparus" do
        it "indique le nombre d'objets disparus par commune" do
          create(:recensement, :disparu, dossier:, objet: create(:objet, commune: dossier.commune))
          expect(commune_dossiers_transmis.first.disparus_count).to eq 1
        end
      end
      context "avec des objets en péril" do
        it "indique le nombre d'objets en péril par commune" do
          create(:recensement, :en_peril, dossier:, objet: create(:objet, commune: dossier.commune))
          expect(commune_dossiers_transmis.first.en_peril_count).to eq 1
        end
      end
    end
  end
end
