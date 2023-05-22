# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dossier, type: :model do
  context "nouveau dossier" do
    let(:commune) { build(:commune) }
    it "est en construction" do
      dossier = Dossier.create!(commune:)
      expect(dossier.reload.status).to eq("construction")
      expect(dossier.reload.submitted_at).to be_nil
    end
  end

  context "status incorrect" do
    let(:dossier) { build(:dossier, status: "blah") }
    subject { dossier.valid? }
    it { should be false }
  end

  context "#submit! avec notes" do
    let!(:commune) { create(:commune, status: :started) }
    let!(:dossier) { create(:dossier, commune:) }
    before { commune.update!(dossier:) }
    subject(:do_submit) { dossier.submit!(notes_commune: "magnifiques objets") }
    it "change le statut du dossier et de la commune et met à jour les notes" do
      do_submit
      expect(dossier.reload.status.to_sym).to eq(:submitted)
      expect(commune.reload.status.to_sym).to eq(:completed)
      expect(dossier.reload.notes_commune).to eq("magnifiques objets")
      expect(commune.reload.completed_at).to be_within(2.seconds).of(Time.zone.now)
    end
  end

  context "#submit! sans notes" do
    let!(:commune) { create(:commune, status: :started) }
    let!(:dossier) { create(:dossier, status: :construction, commune:, notes_commune: "existing notes") }
    before { commune.update!(dossier:) }
    subject(:do_submit) { dossier.submit! }
    it "change le statut du dossier et de la commune sans écraser les notes existantes" do
      do_submit
      expect(dossier.reload.status.to_sym).to eq :submitted
      expect(commune.reload.status.to_sym).to eq :completed
      expect(dossier.reload.notes_commune).to eq "existing notes"
      expect(commune.reload.completed_at).to be_within(2.seconds).of(Time.zone.now)
    end
  end

  context "#submit! avec notes pour une commune inactive" do
    let!(:commune) { create(:commune, status: :inactive) }
    let!(:dossier) { create(:dossier, status: :construction, commune:) }
    before { commune.update!(dossier:) }
    subject(:do_submit) { dossier.submit!(notes_commune: "belles photos") }
    it "échoue avec une exception et annule les changements" do
      expect { do_submit }.to(raise_error { AASM::InvalidTransition })
      # communes.status inactive → completed is not a valid transition
      expect(dossier.reload.status.to_sym).to eq :construction
      expect(commune.reload.status.to_sym).to eq :inactive
      expect(dossier.reload.notes_commune).to be_nil
      expect(commune.reload.completed_at).to be_nil
    end
  end

  context "#submit! avec notes pour une commune déjà completed" do
    let!(:commune) { create(:commune, status: :completed) }
    let!(:dossier) { create(:dossier, status: :construction, commune:) }
    before { commune.update!(dossier:) }
    subject(:do_submit) { dossier.submit!(notes_commune: "joli village") }
    it "échoue avec une exception et annule les changements" do
      expect { do_submit }.to(raise_error { AASM::InvalidTransition })
      # communes.status inactive → completed n’est pas une transition valide
      expect(dossier.reload.status.to_sym).to eq :construction
      expect(commune.reload.status.to_sym).to eq :completed
      expect(dossier.reload.notes_commune).to be_nil
      expect(commune.reload.completed_at).to be_nil
    end
  end

  context "#submit! avec notes mais la commune n’est pas valide" do
    let!(:commune) { create(:commune, status: :started) }
    let!(:dossier) { create(:dossier, commune:, status: :construction) }
    before { commune.update!(dossier:) }
    before { expect(commune).to receive(:valid?).and_return(false) }
    subject(:do_submit) { dossier.submit!(notes_commune: "super moment") }
    it "annule tous les changements" do
      expect { do_submit }.to raise_error(ActiveRecord::RecordInvalid)
      expect(commune.reload.status.to_sym).to eq(:started)
      expect(dossier.reload.status.to_sym).to eq(:construction)
      expect(dossier.reload.notes_commune).to be_nil
    end
  end

  context "#return_to_construction!" do
    let!(:commune) { create(:commune, status: :completed) }
    let!(:dossier) { create(:dossier, commune:, status: :submitted) }
    before { commune.update!(dossier:) }
    subject(:do_return) { dossier.return_to_construction! }
    it "change le statut du dossier et de la commune" do
      do_return
      expect(dossier.reload.status.to_sym).to eq(:construction)
      expect(commune.reload.status.to_sym).to eq(:started)
    end
  end

  context "#return_to_construction! mais la commune n’est pas valide" do
    let!(:commune) { create(:commune, status: :completed) }
    let!(:dossier) { create(:dossier, commune:, status: :submitted) }
    before { commune.update!(dossier:) }
    before { expect(commune).to receive(:valid?).and_return(false) }
    subject(:do_return) { dossier.return_to_construction! }
    it "échoue avec une exception et annule les changements" do
      expect { do_return }.to raise_error(ActiveRecord::RecordInvalid)
      expect(dossier.reload.status.to_sym).to eq :submitted
      expect(commune.reload.status.to_sym).to eq :completed
    end
  end

  context "#accept" do
    let!(:dossier) { create(:dossier, :submitted) }
    it "change le statut du dossier" do
      dossier.accept
      dossier.conservateur = create(:conservateur)
      expect(dossier.valid?).to be true
      dossier.save!
      expect(dossier.accepted_at).to be_within(2.seconds).of(Time.zone.now)
    end
  end

  context "#accept mais sans conservateur" do
    let!(:dossier) { create(:dossier, :submitted) }
    it "n’est pas valide" do
      dossier.accept
      expect(dossier.valid?).to be false
    end
  end

  describe "un dossier existe déjà pour cette commune" do
    let(:commune) { create(:commune) }
    let!(:existing_dossier) { create(:dossier, commune:) }
    let(:dossier) { build(:dossier, commune:) }
    subject { dossier.valid? }
    it { should be false }
  end

  describe "#auto_submittable" do
    # A is auto submittable
    let!(:communeA) { build(:commune) }
    let!(:objetsA) { create_list(:objet, 2, commune: communeA) }
    let!(:dossierA) { create(:dossier, commune: communeA, status: "construction") }
    let!(:recensementA1) { create(:recensement, objet: objetsA[0], dossier: dossierA, created_at: 2.months.ago) }
    let!(:recensementA2) { create(:recensement, objet: objetsA[1], dossier: dossierA, created_at: 2.months.ago) }

    # B is already submitted
    let!(:communeB) { build(:commune) }
    let!(:objetsB) { create_list(:objet, 2, commune: communeB) }
    let!(:dossierB) { create(:dossier, commune: communeB, status: "submitted") }
    let!(:recensementB1) { create(:recensement, objet: objetsB[0], dossier: dossierB, created_at: 2.months.ago) }
    let!(:recensementB2) { create(:recensement, objet: objetsB[1], dossier: dossierB, created_at: 2.months.ago) }

    # C has an objet sans a recensement
    let!(:communeC) { build(:commune) }
    let!(:objetsC) { create_list(:objet, 3, commune: communeC) }
    let!(:dossierC) { create(:dossier, commune: communeC, status: "construction") }
    let!(:recensementC1) { create(:recensement, objet: objetsC[0], dossier: dossierC, created_at: 2.months.ago) }
    let!(:recensementC2) { create(:recensement, objet: objetsC[1], dossier: dossierC, created_at: 2.months.ago) }

    # D has 0 recensements
    let!(:communeD) { build(:commune) }
    let!(:objetsD) { create_list(:objet, 2, commune: communeD) }
    let!(:dossierD) { create(:dossier, commune: communeD, status: "construction") }

    # E is auto submittable too
    let!(:communeE) { build(:commune) }
    let!(:objetsE) { create_list(:objet, 2, commune: communeE) }
    let!(:dossierE) { create(:dossier, commune: communeE, status: "construction") }
    let!(:recensementE1) { create(:recensement, objet: objetsE[0], dossier: dossierE, created_at: 2.months.ago) }
    let!(:recensementE2) { create(:recensement, objet: objetsE[1], dossier: dossierE, created_at: 2.months.ago) }

    # F is too recent
    let!(:communeF) { build(:commune) }
    let!(:objetsF) { create_list(:objet, 2, commune: communeF) }
    let!(:dossierF) { create(:dossier, commune: communeF, status: "construction") }
    let!(:recensementF1) { create(:recensement, objet: objetsF[0], dossier: dossierF, created_at: 1.day.ago) }
    let!(:recensementF2) { create(:recensement, objet: objetsF[1], dossier: dossierF, created_at: 1.day.ago) }

    it "fonctionne" do
      dossiers = Dossier.auto_submittable.to_a
      expect(dossiers).to include(dossierA)
      expect(dossiers).to include(dossierE)
      expect(dossiers).not_to include(dossierB)
      expect(dossiers).not_to include(dossierC)
      expect(dossiers).not_to include(dossierD)
      expect(dossiers).not_to include(dossierF)
    end
  end
end
