# frozen_string_literal: true

require "rails_helper"

describe Conservateurs::DossierPolicy do
  subject { described_class }

  permissions :show? do
    context "dossier accepté d'un departement du conservateur" do
      let(:dossier) { build(:dossier, status: :accepted) }
      let(:conservateur) { build(:conservateur, departements: [dossier.departement] + build_list(:departement, 2)) }
      it { should permit(conservateur, dossier) }
    end

    context "dossier accepté d'un autre departement du conservateur" do
      let(:dossier) { build(:dossier, status: :accepted) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 2)) }
      it { should_not permit(conservateur, dossier) }
    end

    context "dossier rejeté" do
      let(:dossier) { build(:dossier, status: :rejected) }
      let(:conservateur) { build(:conservateur, departements: [dossier.departement] + build_list(:departement, 2)) }
      it { should_not permit(conservateur, dossier) }
    end
  end
end
