# frozen_string_literal: true

require "rails_helper"

describe Conservateurs::CommunePolicy do
  subject { described_class }

  permissions :show? do
    context "commune d'un departement du conservateur" do
      let(:departements) { build_list(:departement, 3) }
      let(:commune1) { build(:commune, departement: departements[1]) }
      let(:conservateur) { build(:conservateur, departements:) }
      it { should permit(conservateur, commune1) }
    end

    context "autre departement" do
      let(:departements) { build_list(:departement, 3) }
      let(:commune) { build(:commune, departement: build(:departement)) }
      let(:conservateur) { build(:conservateur, departements:) }
      it { should_not permit(conservateur, commune) }
    end
  end
end

describe Conservateurs::CommunePolicy::Scope do
  context "quelques departements" do
    let!(:departements1) { create_list(:departement, 2) }
    let!(:communes1a) { create_list(:commune, 2, departement: departements1[0]) }
    let!(:communes1b) { create_list(:commune, 2, departement: departements1[1]) }
    let!(:departements2) { create_list(:departement, 2) }
    let!(:communes2a) { create_list(:commune, 2, departement: departements2[0]) }
    let!(:communes2b) { create_list(:commune, 2, departement: departements2[1]) }
    let!(:conservateur) { create(:conservateur, departements: departements1) }

    it "renvoie les communes des departements du conservateur" do
      communes = described_class.new(conservateur, Commune).resolve
      expect(communes.count).to eq 4
      expect(communes).to include communes1a[0]
      expect(communes).to include communes1a[1]
      expect(communes).to include communes1b[0]
      expect(communes).to include communes1b[1]
      expect(communes).not_to include communes2a[0]
      expect(communes).not_to include communes2a[1]
      expect(communes).not_to include communes2b[0]
      expect(communes).not_to include communes2b[1]
    end
  end
end
