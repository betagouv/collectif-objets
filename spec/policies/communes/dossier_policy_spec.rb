# frozen_string_literal: true

require "rails_helper"

describe Communes::DossierPolicy do
  subject { described_class }

  permissions :show? do
    context "dossier accepté de la commune du user" do
      let(:dossier) { build(:dossier, status: :accepted) }
      let(:user) { build(:user, commune: dossier.commune) }
      it { should permit(user, dossier) }
    end

    context "dossier accepté d'une autre commune" do
      let(:dossier) { build(:dossier, status: :accepted) }
      let(:user) { build(:user, commune: build(:commune)) }
      it { should_not permit(user, dossier) }
    end

    context "dossier rejeté" do
      let(:dossier) { build(:dossier, status: :rejected) }
      let(:user) { build(:user, commune: dossier.commune) }
      it { should permit(user, dossier) }
    end
  end
end
