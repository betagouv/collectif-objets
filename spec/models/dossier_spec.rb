# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dossier, type: :model do
  describe "status updates" do
    let(:commune) { build(:commune) }

    context "new dossier" do
      it "should be in construction" do
        dossier = Dossier.create!(commune:, status: "construction", author_role: "user")
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
end
