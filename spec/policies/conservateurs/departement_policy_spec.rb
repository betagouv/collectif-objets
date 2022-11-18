# frozen_string_literal: true

require "rails_helper"

describe Conservateurs::DepartementPolicy do
  subject { described_class }

  permissions :show? do
    context "departement du conservateur" do
      let(:departements) { build_list(:departement, 3) }
      let(:conservateur) { build(:conservateur, departements:) }
      it { should permit(conservateur, departements[1]) }
    end

    context "autre departement" do
      let(:departements) { build_list(:departement, 3) }
      let(:autre_departement) { build(:departement) }
      let(:conservateur) { build(:conservateur, departements:) }
      it { should_not permit(conservateur, autre_departement) }
    end
  end
end

describe Conservateurs::DepartementPolicy::Scope do
  context "quelques departements" do
    let!(:departements1) { create_list(:departement, 2) }
    let!(:departements2) { create_list(:departement, 2) }
    let!(:conservateur) { create(:conservateur, departements: departements1) }

    it "renvoie les departements du conservateur" do
      departements = described_class.new(conservateur, Departement).resolve
      expect(departements.count).to eq 2
      expect(departements).to include departements1[0]
      expect(departements).to include departements1[1]
      expect(departements).not_to include departements2[0]
      expect(departements).not_to include departements2[1]
    end
  end
end
