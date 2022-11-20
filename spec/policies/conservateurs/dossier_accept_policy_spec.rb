# frozen_string_literal: true

require "rails_helper"

describe Conservateurs::DossierAcceptPolicy do
  subject { described_class }

  permissions :new?, :create?, :update? do
    context "acceptation du dossier d'une commune completed d'un departement du conservateur" do
      let(:commune) { build(:commune, status: :completed) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:, analysed_at: 2.days.ago) }
      let(:dossier) { build(:dossier, commune:, status: :submitted, recensements: [recensement]) }
      let(:dossier_accept) { DossierAccept.new(dossier:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3) + [dossier.departement]) }
      it { should permit(conservateur, dossier_accept) }
    end

    context "acceptation du dossier d'un autre departement" do
      let(:commune) { build(:commune, status: :completed) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:, analysed_at: 2.days.ago) }
      let(:dossier) { build(:dossier, commune:, status: :submitted, recensements: [recensement]) }
      let(:dossier_accept) { DossierAccept.new(dossier:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3)) }
      it { should permit(conservateur, dossier_accept) }
    end

    context "acceptation du dossier d'une commune started" do
      let(:commune) { build(:commune, status: :started) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:, analysed_at: 2.days.ago) }
      let(:dossier) { build(:dossier, commune:, status: :submitted, recensements: [recensement]) }
      let(:dossier_accept) { DossierAccept.new(dossier:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3) + [dossier.departement]) }
      it { should_not permit(conservateur, dossier_accept) }
    end

    context "acceptation du dossier deja accepté " do
      let(:commune) { build(:commune, status: :completed) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:, analysed_at: 2.days.ago) }
      let(:dossier) { build(:dossier, commune:, status: :accepted, recensements: [recensement]) }
      let(:dossier_accept) { DossierAccept.new(dossier:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3) + [dossier.departement]) }
      it { should_not permit(conservateur, dossier_accept) }
    end

    context "acceptation du dossier mais certains recensements n'ont pas été analysés " do
      let!(:commune) { create(:commune, status: :completed) }
      let!(:objet1) { create(:objet, commune:) }
      let!(:objet2) { create(:objet, commune:) }
      let!(:dossier) { create(:dossier, commune:, status: :submitted) }
      let!(:recensement1) { create(:recensement, objet: objet1, dossier:, analysed_at: 2.days.ago) }
      let!(:recensement2) { create(:recensement, objet: objet2, dossier:, analysed_at: nil) }
      let!(:dossier_accept) { DossierAccept.new(dossier:) }
      let!(:conservateur) { create(:conservateur, departements: build_list(:departement, 3) + [dossier.departement]) }
      it { should_not permit(conservateur, dossier_accept) }
    end
  end
end
