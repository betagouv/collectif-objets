# frozen_string_literal: true

require "rails_helper"

describe Recenseurs::CommunePolicy do
  subject { described_class }

  let!(:departement) { create(:departement) }

  permissions :show?, :historique? do
    context "commune with edifice access" do
      let!(:commune) { create(:commune, :with_edifices, departement:) }
      let!(:recenseur) { create(:recenseur) }
      let!(:access) { create(:recenseur_access, recenseur:, commune:, granted: true, all_edifices: true) }

      it { should permit(recenseur, commune) }
    end

    context "commune with specific edifice access" do
      let!(:commune) { create(:commune, :with_edifices, departement:) }
      let!(:recenseur) { create(:recenseur) }
      let!(:access) do
        commune.reload
        some_edifice_id = commune.edifices.first.id
        access = create(:recenseur_access, recenseur:, commune:, granted: false,
                                           all_edifices: false, edifice_ids: [])
        access.update_columns(granted: true, edifice_ids: [some_edifice_id])
        access
      end

      it { should permit(recenseur, commune) }
    end

    context "commune with no edifice access" do
      let!(:commune) { create(:commune, :with_edifices, departement:) }
      let!(:recenseur) { create(:recenseur) }
      let!(:access) do
        access = create(:recenseur_access, recenseur:, commune:, granted: false,
                                           all_edifices: false, edifice_ids: [])
        access.update_column(:granted, true) # Skip callbacks to keep edifice_ids empty
        access
      end

      it { should_not permit(recenseur, commune) }
    end

    context "commune with non-granted access" do
      let!(:commune) { create(:commune, :with_edifices, departement:) }
      let!(:recenseur) { create(:recenseur) }
      let!(:access) do
        create(:recenseur_access, recenseur:, commune:, granted: false,
                                  all_edifices: true)
      end

      it { should_not permit(recenseur, commune) }
    end

    context "commune with no access at all" do
      let!(:commune) { create(:commune, :with_edifices, departement:) }
      let!(:recenseur) { create(:recenseur) }

      it { should_not permit(recenseur, commune) }
    end
  end
end

describe Recenseurs::CommunePolicy::Scope do
  subject(:communes) { described_class.new(recenseur, Commune).resolve }

  context "multiple communes with different access levels" do
    let!(:departement) { create(:departement) }

    let!(:commune_with_all_edifices) { create(:commune, :with_edifices, departement:, nom: "all_edifices") }
    let!(:commune_with_some_edifices) { create(:commune, :with_edifices, departement:, nom: "some_edifices") }
    let!(:commune_with_no_edifices) { create(:commune, :with_edifices, departement:, nom: "no_edifices") }
    let!(:commune_no_access) { create(:commune, :with_edifices, departement:, nom: "no_access") }
    let!(:recenseur) { create(:recenseur) }

    before do
      create(:recenseur_access, recenseur:, commune: commune_with_all_edifices,
                                granted: true, all_edifices: true)
      # Create access for some edifices by bypassing callbacks that might filter edifice_ids
      commune_with_some_edifices.reload
      some_edifice_id = commune_with_some_edifices.edifices.first.id
      access_some_edifices = create(:recenseur_access, recenseur:, commune: commune_with_some_edifices,
                                                       granted: false, all_edifices: false, edifice_ids: [])
      access_some_edifices.update_columns(granted: true, edifice_ids: [some_edifice_id])
      # Create access with granted: false first, then update to granted: true to avoid ensure_consistency
      access_no_edifices = create(:recenseur_access, recenseur:, commune: commune_with_no_edifices,
                                                     granted: false, all_edifices: false, edifice_ids: [])
      access_no_edifices.update_column(:granted, true) # Skip callbacks
    end

    it "returns only communes with edifice access" do
      expect(communes.count).to eq 2
      expect(communes).to include commune_with_all_edifices
      expect(communes).to include commune_with_some_edifices
      expect(communes).not_to include commune_with_no_edifices
      expect(communes).not_to include commune_no_access
    end
  end
end
