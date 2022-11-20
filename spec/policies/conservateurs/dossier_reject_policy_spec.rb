# frozen_string_literal: true

require "rails_helper"

describe Conservateurs::DossierRejectPolicy do
  subject { described_class }

  permissions :new?, :create?, :update? do
    context "rejection du dossier d'une commune completed d'un departement du conservateur" do
      let(:commune) { build(:commune, status: :completed) }
      let(:dossier) { build(:dossier, commune:, status: :submitted) }
      let(:dossier_reject) { DossierAccept.new(dossier:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3) + [dossier.departement]) }
      it { should permit(conservateur, dossier_reject) }
    end

    context "rejection du dossier d'une commune started" do
      let(:commune) { build(:commune, status: :started) }
      let(:dossier) { build(:dossier, commune:, status: :submitted) }
      let(:dossier_reject) { DossierAccept.new(dossier:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3) + [dossier.departement]) }
      it { should_not permit(conservateur, dossier_reject) }
    end

    context "rejection d'un dossier accepted" do
      let(:commune) { build(:commune, status: :completed) }
      let(:dossier) { build(:dossier, commune:, status: :accepted) }
      let(:dossier_reject) { DossierAccept.new(dossier:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3) + [dossier.departement]) }
      it { should_not permit(conservateur, dossier_reject) }
    end

    context "rejection d'un dossier d'un autre departement" do
      let(:commune) { build(:commune, status: :started) }
      let(:dossier) { build(:dossier, commune:, status: :submitted) }
      let(:dossier_reject) { DossierAccept.new(dossier:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3)) }
      it { should_not permit(conservateur, dossier_reject) }
    end
  end
end
