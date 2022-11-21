# frozen_string_literal: true

require "rails_helper"

describe Communes::DossierPolicy do
  subject { described_class }

  permissions :show? do
    context "dossier accepted de la commune du user" do
      let(:dossier) { build(:dossier, status: :accepted) }
      let(:user) { build(:user, commune: dossier.commune) }
      it { should permit(user, dossier) }
    end

    context "dossier accepted d'une autre commune" do
      let(:dossier) { build(:dossier, status: :accepted) }
      let(:user) { build(:user, commune: build(:commune)) }
      it { should_not permit(user, dossier) }
    end

    context "dossier rejected" do
      let(:dossier) { build(:dossier, status: :rejected) }
      let(:user) { build(:user) }
      it { should_not permit(user, dossier) }
    end
  end
end
