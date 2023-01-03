# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dossier, type: :model do
  describe "status updates" do
    let(:commune) { build(:commune) }

    context "new dossier" do
      it "should be in construction" do
        dossier = Dossier.create!(commune:, status: "construction")
        expect(dossier.status).to eq("construction")
        expect(dossier.submitted_at).to be_nil
      end
    end

    context "bad status" do
      let(:dossier) { build(:dossier, status: "blah") }
      subject { dossier.valid? }
      it { should be false }
    end

    context "dossier gets submitted" do
      let!(:dossier) { create(:dossier) }
      it "should set timestamps" do
        dossier.submit!
        expect(dossier.status).to eq("submitted")
        expect(dossier.submitted_at).to be_within(2.seconds).of(Time.zone.now)
      end
    end

    context "dossier gets submitted with notes" do
      let!(:dossier) { create(:dossier) }
      it "should set the notes" do
        dossier.submit!(notes_commune: "blah blah")
        expect(dossier.reload.notes_commune).to eq("blah blah")
      end
    end

    context "dossier gets submitted for started commune" do
      let!(:commune) { create(:commune, status: Commune::STATE_STARTED) }
      let!(:dossier) { create(:dossier, commune:) }
      it "should complete the commune" do
        dossier.submit!
        expect(commune.status.to_sym).to eq(Commune::STATE_COMPLETED)
        expect(commune.completed_at).to be_within(2.seconds).of(Time.zone.now)
      end
    end

    context "dossier gets submitted for completed commune" do
      let!(:commune) { create(:commune, status: Commune::STATE_COMPLETED, completed_at: 2.days.ago) }
      let!(:dossier) { create(:dossier, commune:) }
      it "should not re-complete the commune" do
        dossier.submit!
        expect(commune.status.to_sym).to eq(Commune::STATE_COMPLETED)
        expect(commune.completed_at).not_to be_within(2.seconds).of(Time.zone.now)
      end
    end

    context "dossier gets rejected" do
      let!(:dossier) { create(:dossier, :submitted) }
      it "should set timestamps" do
        dossier.reject!
        expect(dossier.status).to eq("rejected")
        expect(dossier.rejected_at).to be_within(2.seconds).of(Time.zone.now)
      end
    end

    context "dossier gets accepted but missing conservateur" do
      let!(:dossier) { create(:dossier, :submitted) }
      it "should be invalid" do
        dossier.accept
        expect(dossier.valid?).to be false
      end
    end

    context "dossier gets accepted" do
      let!(:dossier) { create(:dossier, :submitted) }
      it "should be invalid" do
        dossier.accept
        dossier.conservateur = create(:conservateur)
        expect(dossier.valid?).to be true
        dossier.save!
        expect(dossier.accepted_at).to be_within(2.seconds).of(Time.zone.now)
      end
    end
  end

  describe "commune unicity" do
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

    # C has an objet without a recensement
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

    it "should work" do
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
