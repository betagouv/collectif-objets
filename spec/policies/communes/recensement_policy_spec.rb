# frozen_string_literal: true

require "rails_helper"

describe Communes::RecensementPolicy do
  subject { described_class }

  permissions :new?, :create? do
    context "objet n'a pas de recensement + commune inactive" do
      let(:commune) { build(:commune, status: :inactive) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:, dossier: commune.dossier) }
      let(:user) { build(:user, commune:) }
      it { should permit(user, recensement) }
    end

    context "objet n'a pas de recensement + commune inactive MAIS autre commune" do
      let(:commune) { build(:commune, :en_cours_de_recensement) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:, dossier: commune.dossier) }
      let(:user) { build(:user, commune: build(:commune)) }
      it { should_not permit(user, recensement) }
    end

    context "objet n'a pas de recensement + commune started" do
      let(:commune) { build(:commune, :en_cours_de_recensement) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:, dossier: commune.dossier) }
      let(:user) { build(:user, commune:) }
      it { should permit(user, recensement) }
    end

    context "objet n'a pas de recensement + commune completed" do
      # this is a rare case where an object is created after the commune is completed
      let(:commune) { build(:commune, :completed) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:, dossier: commune.dossier) }
      let(:user) { build(:user, commune:) }
      it { should permit(user, recensement) }
    end
  end

  permissions :edit?, :update?, :destroy? do
    context "commune started" do
      let(:commune) { build(:commune, :en_cours_de_recensement) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:, dossier: commune.dossier) }
      let(:user) { build(:user, commune:) }

      it { should permit(user, recensement) }
    end

    context "commune started MAIS autre commune" do
      let(:commune) { build(:commune, :en_cours_de_recensement) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:, dossier: commune.dossier) }
      let(:user) { build(:user, commune: build(:commune)) }

      it { should_not permit(user, recensement) }
    end

    context "commune completed + dossier submitted" do
      let(:commune) { build(:commune, :completed) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:, dossier: commune.dossier) }
      let(:user) { build(:user, commune:) }

      it { should permit(user, recensement) }
    end

    context "commune completed + dossier accepted" do
      let(:commune) { build(:commune, :examinée) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:, dossier: commune.dossier) }
      let(:user) { build(:user, commune:) }

      it { should_not permit(user, recensement) }
    end
  end
end
