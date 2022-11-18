# frozen_string_literal: true

require "rails_helper"

describe Communes::RecensementPolicy do
  subject { described_class }

  permissions :new?, :create? do
    context "objet n'a pas de recensement + commune inactive" do
      let(:commune) { build(:commune, status: :inactive) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:) }
      let(:user) { build(:user, commune:) }
      it { should permit(user, recensement) }
    end

    context "objet n'a pas de recensement + commune inactive MAIS autre commune" do
      let(:commune) { build(:commune, status: :inactive) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:) }
      let(:user) { build(:user, commune: build(:commune)) }
      it { should_not permit(user, recensement) }
    end

    context "objet n'a pas de recensement + commune completed" do
      let(:commune) { build(:commune, status: :completed) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:) }
      let(:user) { build(:user, commune:) }
      it { should_not permit(user, recensement) }
    end

    context "objet n'a pas de recensement + commune completed + dossier rejected" do
      let(:commune) { build(:commune, status: :completed) }
      let(:dossier) { build(:dossier, status: :rejected, commune:) }
      before { commune.dossier = dossier }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:) }
      let(:user) { build(:user, commune:) }

      it { should permit(user, recensement) }
    end

    context "objet a deja un recensement + commune started" do
      let(:commune) { build(:commune, status: :started) }
      let(:objet) { build(:objet, :with_recensement, commune:) }
      let(:recensement) { build(:recensement, objet:) }
      let(:user) { build(:user, commune:) }

      it { should_not permit(user, recensement) }
    end
  end

  permissions :edit?, :update? do
    context "commune started" do
      let(:commune) { build(:commune, status: :started) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:) }
      let(:user) { build(:user, commune:) }

      it { should permit(user, recensement) }
    end

    context "commune started MAIS autre commune" do
      let(:commune) { build(:commune, status: :started) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:) }
      let(:user) { build(:user, commune: build(:commune)) }

      it { should_not permit(user, recensement) }
    end

    context "commune completed + dossier submitted" do
      let(:commune) { build(:commune, status: :completed) }
      let(:dossier) { build(:dossier, status: :submitted, commune:) }
      before { commune.dossier = dossier }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:) }
      let(:user) { build(:user, commune:) }

      it { should_not permit(user, recensement) }
    end

    context "commune completed + dossier rejected" do
      let(:commune) { build(:commune, status: :completed) }
      let(:dossier) { build(:dossier, status: :rejected, commune:) }
      before { commune.dossier = dossier }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:) }
      let(:user) { build(:user, commune:) }

      it { should permit(user, recensement) }
    end
  end
end
