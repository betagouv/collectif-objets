# frozen_string_literal: true

require "rails_helper"

describe Communes::DossierRecompletionPolicy do
  subject { described_class }

  permissions :new?, :create? do
    context "commune du user + dossier rejected" do
      let(:commune) { build(:commune, status: :completed) }
      let(:dossier) { build(:dossier, commune:, status: :rejected) }
      let(:user) { build(:user, commune:) }
      let(:dossier_recompletion) { DossierRecompletion.new(dossier:) }
      it { should permit(user, dossier_recompletion) }
    end

    context "commune du user + dossier accepted" do
      let(:commune) { build(:commune, status: :completed) }
      let(:dossier) { build(:dossier, commune:, status: :accepted) }
      let(:user) { build(:user, commune:) }
      let(:dossier_recompletion) { DossierRecompletion.new(dossier:) }
      it { should_not permit(user, dossier_recompletion) }
    end

    context "autre commune du user + dossier rejected" do
      let(:commune) { build(:commune, status: :completed) }
      let(:dossier) { build(:dossier, commune:, status: :rejected) }
      let(:user) { build(:user, commune: build(:commune)) }
      let(:dossier_recompletion) { DossierRecompletion.new(dossier:) }
      it { should_not permit(user, dossier_recompletion) }
    end
  end
end
