# frozen_string_literal: true

require "rails_helper"

describe Conservateurs::AnalysePolicy do
  subject { described_class }

  permissions :edit?, :update? do
    context "examen d'une commune completed dossier submitted d'un departement du conservateur" do
      let(:commune) { build(:commune, status: :completed) }
      let(:objet) { build(:objet, commune:) }
      let(:dossier) { build(:dossier, commune:, status: :submitted) }
      let(:recensement) { create(:recensement, objet:, dossier:) }
      let(:analyse) { Analyse.new(recensement:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3) + [analyse.departement]) }
      it { should permit(conservateur, analyse) }
    end

    context "examen d'une commune started" do
      let(:commune) { build(:commune, status: :started) }
      let(:objet) { build(:objet, commune:) }
      let(:dossier) { build(:dossier, commune:, status: :submitted) }
      let(:recensement) { create(:recensement, objet:, dossier:) }
      let(:analyse) { Analyse.new(recensement:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3) + [analyse.departement]) }
      it { should_not permit(conservateur, analyse) }
    end

    context "examen d'une commune d'un autre departement" do
      let(:commune) { build(:commune, status: :completed) }
      let(:objet) { build(:objet, commune:) }
      let(:dossier) { build(:dossier, commune:, status: :submitted) }
      let(:recensement) { build(:recensement, objet:, dossier:) }
      let(:analyse) { Analyse.new(recensement:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3)) }
      it { should_not permit(conservateur, analyse) }
    end
  end
end
