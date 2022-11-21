# frozen_string_literal: true

require "rails_helper"

describe Communes::DossierCompletionPolicy do
  subject { described_class }

  permissions :show? do
    context "commune du user + completed" do
      let(:commune) { build(:commune, status: :completed) }
      let(:dossier) { build(:dossier, commune:, status: :submitted) }
      before { commune.dossier = dossier }
      let(:user) { build(:user, commune:) }
      let(:dossier_completion) { DossierCompletion.new(dossier:) }
      it { should permit(user, dossier_completion) }
    end

    context "commune du user + started" do
      let(:commune) { build(:commune, status: :started) }
      let(:dossier) { build(:dossier, commune:, status: :construction) }
      before { commune.dossier = dossier }
      let(:user) { build(:user, commune:) }
      let(:dossier_completion) { DossierCompletion.new(dossier:) }
      it { should_not permit(user, dossier_completion) }
    end

    context "autre commune" do
      let(:commune1) { build(:commune, status: :completed) }
      let(:commune2) { build(:commune, status: :completed) }
      let(:dossier1) { build(:dossier, commune: commune1, status: :submitted) }
      before { commune1.dossier = dossier1 }
      let(:dossier2) { build(:dossier, commune: commune2, status: :submitted) }
      before { commune1.dossier = dossier2 }
      let(:user) { build(:user, commune: commune2) }
      let(:dossier_completion) { DossierCompletion.new(dossier: dossier1) }
      it { should_not permit(user, dossier_completion) }
    end
  end

  permissions :new?, :create? do
    context "commune du user + started" do
      let(:commune) { build(:commune, status: :started) }
      let(:dossier) { build(:dossier, commune:, status: :construction) }
      let(:user) { build(:user, commune:) }
      let(:dossier_completion) { DossierCompletion.new(dossier:) }
      it { should permit(user, dossier_completion) }
    end

    context "commune du user + completed" do
      let(:commune) { build(:commune, status: :completed) }
      let(:dossier) { build(:dossier, commune:, status: :submitted) }
      before { commune.dossier = dossier }
      let(:user) { build(:user, commune:) }
      let(:dossier_completion) { DossierCompletion.new(dossier:) }
      it { should_not permit(user, dossier_completion) }
    end

    context "autre commune" do
      let(:commune1) { build(:commune, status: :started) }
      let(:commune2) { build(:commune, status: :started) }
      let(:dossier1) { build(:dossier, commune: commune1, status: :construction) }
      before { commune1.dossier = dossier1 }
      let(:dossier2) { build(:dossier, commune: commune2, status: :construction) }
      before { commune1.dossier = dossier2 }
      let(:user) { build(:user, commune: commune2) }
      let(:dossier_completion) { DossierCompletion.new(dossier: dossier1) }
      it { should_not permit(user, dossier_completion) }
    end
  end
end
