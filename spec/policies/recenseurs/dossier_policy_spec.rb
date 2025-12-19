# frozen_string_literal: true

require "rails_helper"

describe Recenseurs::DossierPolicy do
  subject { described_class }

  let(:commune) { build(:commune) }
  let(:dossier) { build(:dossier, commune:, status: :accepted) }

  permissions :show? do
    context "when recenseur has full access to the commune" do
      let(:recenseur) { create(:recenseur) }
      let!(:access) { create(:recenseur_access, recenseur:, commune:, granted: true, all_edifices: true) }

      it { should permit(recenseur, dossier) }
    end

    context "when recenseur has partial access to the commune" do
      let(:commune) { create(:commune, :with_edifices) }
      let(:dossier) { build(:dossier, commune:, status: :accepted) }
      let(:recenseur) { create(:recenseur) }
      let!(:access) do
        # Get one edifice ID from the commune (which has multiple edifices)
        edifice_id = commune.edifices.first.id
        create(:recenseur_access, recenseur:, commune:, granted: true, all_edifices: false,
                                  edifice_ids: [edifice_id])
      end

      it { should_not permit(recenseur, dossier) }
    end

    context "when recenseur has no access to the commune" do
      let(:recenseur) { create(:recenseur) }

      it { should_not permit(recenseur, dossier) }
    end

    context "when recenseur has pending access to the commune" do
      let(:recenseur) { create(:recenseur) }
      let!(:access) { create(:recenseur_access, recenseur:, commune:, granted: nil, all_edifices: true) }

      it { should_not permit(recenseur, dossier) }
    end

    context "when recenseur has revoked access to the commune" do
      let(:recenseur) { create(:recenseur) }
      let!(:access) { create(:recenseur_access, recenseur:, commune:, granted: false, all_edifices: true) }

      it { should_not permit(recenseur, dossier) }
    end

    context "when recenseur has full access to a different commune" do
      let(:recenseur) { create(:recenseur) }
      let(:other_commune) { build(:commune) }
      let!(:access) { create(:recenseur_access, recenseur:, commune: other_commune, granted: true, all_edifices: true) }

      it { should_not permit(recenseur, dossier) }
    end
  end
end
