# frozen_string_literal: true

require "rails_helper"

describe Recenseurs::DossierCompletionPolicy do
  subject { described_class }

  permissions :show? do
    context "recenseur avec accès complet + commune completed" do
      let(:commune) { build(:commune, status: :completed) }
      let(:dossier) { build(:dossier, commune:, status: :submitted) }
      before { commune.dossier = dossier }
      let(:recenseur) { build(:recenseur) }
      let(:dossier_completion) { DossierCompletion.new(dossier:) }
      before do
        allow(recenseur).to receive_message_chain(:granted_accesses, :where).with(commune:, all_edifices: true).and_return(double(exists?: true))
      end
      it { should permit(recenseur, dossier_completion) }
    end

    context "recenseur avec accès complet + commune started" do
      let(:commune) { build(:commune, status: :started) }
      let(:dossier) { build(:dossier, commune:, status: :construction) }
      before { commune.dossier = dossier }
      let(:recenseur) { build(:recenseur) }
      let(:dossier_completion) { DossierCompletion.new(dossier:) }
      before do
        allow(recenseur).to receive_message_chain(:granted_accesses, :where).with(commune:, all_edifices: true).and_return(double(exists?: true))
      end
      it { should_not permit(recenseur, dossier_completion) }
    end

    context "recenseur sans accès complet" do
      let(:commune) { build(:commune, status: :completed) }
      let(:dossier) { build(:dossier, commune:, status: :submitted) }
      before { commune.dossier = dossier }
      let(:recenseur) { build(:recenseur) }
      let(:dossier_completion) { DossierCompletion.new(dossier:) }
      before do
        allow(recenseur).to receive_message_chain(:granted_accesses, :where).with(commune:, all_edifices: true).and_return(double(exists?: false))
      end
      it { should_not permit(recenseur, dossier_completion) }
    end

    context "autre commune" do
      let(:commune1) { build(:commune, status: :completed) }
      let(:commune2) { build(:commune, status: :completed) }
      let(:dossier1) { build(:dossier, commune: commune1, status: :submitted) }
      before { commune1.dossier = dossier1 }
      let(:recenseur) { build(:recenseur) }
      let(:dossier_completion) { DossierCompletion.new(dossier: dossier1) }
      before do
        allow(recenseur).to receive_message_chain(:granted_accesses, :where).with(commune: commune1, all_edifices: true).and_return(double(exists?: false))
      end
      it { should_not permit(recenseur, dossier_completion) }
    end
  end

  permissions :new?, :create? do
    context "recenseur avec accès complet + commune started" do
      let(:commune) { build(:commune, status: :started) }
      let(:dossier) { build(:dossier, commune:, status: :construction) }
      let(:recenseur) { build(:recenseur) }
      let(:dossier_completion) { DossierCompletion.new(dossier:) }
      before do
        allow(recenseur).to receive_message_chain(:granted_accesses, :where).with(commune:, all_edifices: true).and_return(double(exists?: true))
      end
      it { should permit(recenseur, dossier_completion) }
    end

    context "recenseur avec accès complet + commune completed" do
      let(:commune) { build(:commune, status: :completed) }
      let(:dossier) { build(:dossier, commune:, status: :submitted) }
      before { commune.dossier = dossier }
      let(:recenseur) { build(:recenseur) }
      let(:dossier_completion) { DossierCompletion.new(dossier:) }
      before do
        allow(recenseur).to receive_message_chain(:granted_accesses, :where).with(commune:, all_edifices: true).and_return(double(exists?: true))
      end
      it { should_not permit(recenseur, dossier_completion) }
    end

    context "recenseur sans accès complet + commune started" do
      let(:commune) { build(:commune, status: :started) }
      let(:dossier) { build(:dossier, commune:, status: :construction) }
      let(:recenseur) { build(:recenseur) }
      let(:dossier_completion) { DossierCompletion.new(dossier:) }
      before do
        allow(recenseur).to receive_message_chain(:granted_accesses, :where).with(commune:, all_edifices: true).and_return(double(exists?: false))
      end
      it { should_not permit(recenseur, dossier_completion) }
    end

    context "autre commune" do
      let(:commune1) { build(:commune, status: :started) }
      let(:commune2) { build(:commune, status: :started) }
      let(:dossier1) { build(:dossier, commune: commune1, status: :construction) }
      before { commune1.dossier = dossier1 }
      let(:recenseur) { build(:recenseur) }
      let(:dossier_completion) { DossierCompletion.new(dossier: dossier1) }
      before do
        allow(recenseur).to receive_message_chain(:granted_accesses, :where).with(commune: commune1, all_edifices: true).and_return(double(exists?: false))
      end
      it { should_not permit(recenseur, dossier_completion) }
    end
  end
end
