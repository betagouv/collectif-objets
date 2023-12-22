# frozen_string_literal: true

require "rails_helper"

describe Conservateurs::ActiveStorage::AttachmentPolicy do
  subject { described_class }

  permissions :update?, :destroy? do
    context "photo d'une commune completed dossier submitted d'un departement du conservateur" do
      let(:commune) { build(:commune, status: :completed) }
      let(:objet) { build(:objet, commune:) }
      let(:dossier) { build(:dossier, commune:, status: :submitted) }
      let(:recensement) { build(:recensement, :with_photo, objet:, dossier:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3) + [recensement.departement]) }
      it { should permit(conservateur, recensement.photos[0]) }
    end

    context "photo d'une commune started dossier construction d'un departement du conservateur" do
      let(:commune) { build(:commune, status: :started) }
      let(:objet) { build(:objet, commune:) }
      let(:dossier) { build(:dossier, commune:, status: :construction) }
      let(:recensement) { build(:recensement, :with_photo, objet:, dossier:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3) + [recensement.departement]) }
      it { should_not permit(conservateur, recensement.photos[0]) }
    end

    context "photo d'une commune completed dossier submitted d'un autre departement que ceux du conservateur" do
      let(:commune) { build(:commune, status: :completed) }
      let(:objet) { build(:objet, commune:) }
      let(:dossier) { build(:dossier, commune:, status: :submitted) }
      let(:recensement) { build(:recensement, :with_photo, objet:, dossier:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3)) }
      it { should_not permit(conservateur, recensement.photos[0]) }
    end
  end
end
