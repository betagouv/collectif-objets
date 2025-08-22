# frozen_string_literal: true

require "rails_helper"

RSpec.describe Conservateurs::RecenseurPolicy do
  let(:departement) { create(:departement) }
  let(:other_departement) { create(:departement, code: "99") }
  let(:conservateur) { create(:conservateur, departements: [departement]) }
  let(:commune) { create(:commune, departement:) }
  let(:other_commune) { create(:commune, departement: other_departement) }

  describe "#show?" do
    let(:policy) { described_class.new(conservateur, recenseur) }

    context "when recenseur has granted access to conservateur's département" do
      let(:recenseur) { create(:recenseur) }
      before { create(:recenseur_access, recenseur:, commune:, granted: true) }

      it "allows access" do
        expect(policy.show?).to be true
      end
    end

    context "when recenseur has pending access to conservateur's département" do
      let(:recenseur) { create(:recenseur) }
      before { create(:recenseur_access, recenseur:, commune:, granted: nil) }

      it "allows access" do
        expect(policy.show?).to be true
      end
    end

    context "when recenseur has rejected access to conservateur's département" do
      let(:recenseur) { create(:recenseur) }
      before { create(:recenseur_access, recenseur:, commune:, granted: false) }

      it "allows access" do
        expect(policy.show?).to be true
      end
    end

    context "when recenseur has no access" do
      let(:recenseur) { create(:recenseur) }

      it "allows access" do
        expect(policy.show?).to be true
      end
    end

    context "when recenseur has access only to other départements" do
      let(:recenseur) { create(:recenseur) }
      before { create(:recenseur_access, recenseur:, commune: other_commune, granted: true) }

      it "denies access" do
        expect(policy.show?).to be false
      end
    end
  end

  describe "Scope" do
    subject { Conservateurs::RecenseurPolicy::Scope.new(conservateur, Recenseur).resolve }

    let!(:recenseur_with_granted_access) do
      recenseur = create(:recenseur)
      create(:recenseur_access, recenseur:, commune:, granted: true)
      recenseur
    end

    let!(:recenseur_with_pending_access) do
      recenseur = create(:recenseur)
      create(:recenseur_access, recenseur:, commune:, granted: nil)
      recenseur
    end

    let!(:recenseur_with_rejected_access) do
      recenseur = create(:recenseur)
      create(:recenseur_access, recenseur:, commune:, granted: false)
      recenseur
    end

    let!(:recenseur_no_access) { create(:recenseur) }

    let!(:recenseur_other_departement) do
      recenseur = create(:recenseur)
      create(:recenseur_access, recenseur:, commune: other_commune, granted: true)
      recenseur
    end

    it "includes recenseurs with granted access to conservateur's départements" do
      expect(subject).to include(recenseur_with_granted_access)
    end

    it "includes recenseurs with pending access to conservateur's départements" do
      expect(subject).to include(recenseur_with_pending_access)
    end

    it "includes recenseurs with rejected access to conservateur's départements" do
      expect(subject).to include(recenseur_with_rejected_access)
    end

    it "includes recenseurs with no access" do
      expect(subject).to include(recenseur_no_access)
    end

    it "excludes recenseurs with access only to other départements" do
      expect(subject).not_to include(recenseur_other_departement)
    end
  end
end
