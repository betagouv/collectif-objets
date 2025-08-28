# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecenseurAccess, type: :model do
  let(:access) { build(:recenseur_access) }
  let(:recenseur) { create(:recenseur) }
  let(:commune) { create(:commune) }

  describe "scopes" do
    let(:recenseur) { create(:recenseur) }
    let(:commune1) { create(:commune) }
    let(:commune2) { create(:commune) }
    let(:commune3) { create(:commune) }

    before do
      create(:recenseur_access, :newly_granted, recenseur:, commune: commune1)
      create(:recenseur_access, :newly_revoked, recenseur:, commune: commune2)
      create(:recenseur_access, recenseur:, commune: commune3, granted: true, notified: true)
    end

    describe ".granted" do
      it "returns all granted accesses" do
        granted = RecenseurAccess.granted
        expect(granted.count).to eq(2)
        expect(granted.map(&:commune)).to contain_exactly(commune1, commune3)
      end
    end

    describe ".newly_granted" do
      it "returns granted accesses that are not yet notified" do
        newly_granted = RecenseurAccess.newly_granted
        expect(newly_granted.count).to eq(1)
        expect(newly_granted.first.commune).to eq(commune1)
        expect(newly_granted.first.granted).to be true
        expect(newly_granted.first.notified).to be false
      end
    end

    describe ".newly_revoked" do
      it "returns revoked accesses that are not yet notified" do
        newly_revoked = RecenseurAccess.newly_revoked
        expect(newly_revoked.count).to eq(1)
        expect(newly_revoked.first.commune).to eq(commune2)
        expect(newly_revoked.first.granted).to be false
        expect(newly_revoked.first.notified).to be false
      end
    end
  end

  describe "callbacks" do
    describe "#reset_notified_if_granted_changed" do
      let(:access) { create(:recenseur_access, recenseur:, commune:, granted:, notified:) }

      context "when access is initially granted and notified" do
        let(:granted) { true }
        let(:notified) { true }

        it "resets notified to false when access is revoked" do
          expect { access.update!(granted: false) }.to change { access.notified }.from(true).to(false)
        end

        it "resets notified to false when access becomes pending" do
          expect { access.update!(granted: nil) }.to change { access.notified }.from(true).to(false)
        end
      end

      context "when access is initially revoked and notified" do
        let(:granted) { false }
        let(:notified) { true }

        it "resets notified to false when access is granted" do
          expect { access.update!(granted: true) }.to change { access.notified }.from(true).to(false)
        end
      end

      context "when access is initially pending and notified" do
        let(:granted) { nil }
        let(:notified) { true }

        it "resets notified to false when access is granted" do
          expect { access.update!(granted: true) }.to change { access.notified }.from(true).to(false)
        end

        it "resets notified to false when access is revoked" do
          expect { access.update!(granted: false) }.to change { access.notified }.from(true).to(false)
        end
      end
    end

    describe "#grant_all_edifices_if_all_edifices_selected" do
      let!(:edifice1) { create(:edifice, commune:) }
      let!(:edifice2) { create(:edifice, commune:) }

      it "sets all_edifices to true when edifice_ids contains all commune edifices" do
        access = build(:recenseur_access, recenseur:, commune:, edifice_ids: [edifice1.id, edifice2.id])
        access.save!
        expect(access.all_edifices).to be true
      end

      it "keeps all_edifices false when edifice_ids contains only some commune edifices" do
        access = build(:recenseur_access, recenseur:, commune:, all_edifices: false, edifice_ids: [edifice1.id])
        access.save!
        expect(access.all_edifices).to be false
      end

      it "keeps all_edifices false when edifice_ids is empty" do
        access = build(:recenseur_access, recenseur:, commune:, all_edifices: false, edifice_ids: [])
        expect(access.valid?).to be false # Should be invalid due to presence validation
        expect(access.all_edifices).to be false
      end
    end
  end

  describe "validations" do
    let(:edifice1) { create(:edifice, commune:) }
    let(:edifice2) { create(:edifice, commune:) }
    let(:other_edifice) { create(:edifice) }

    describe "edifice_ids presence" do
      it "is valid when all_edifices is true and edifice_ids is empty" do
        access = build(:recenseur_access, recenseur:, commune:, all_edifices: true, edifice_ids: [])
        expect(access).to be_valid
      end

      it "is invalid when all_edifices is false and edifice_ids is empty" do
        access = build(:recenseur_access, recenseur:, commune:, all_edifices: false, edifice_ids: [])
        expect(access).not_to be_valid
        expect(access.errors[:edifice_ids]).to include("doit être rempli(e)")
      end

      it "is valid when all_edifices is false and edifice_ids contains valid ids" do
        access = build(:recenseur_access, recenseur:, commune:, all_edifices: false, edifice_ids: [edifice1.id])
        expect(access).to be_valid
      end
    end

    describe "edifice_ids belong to commune" do
      it "is valid when edifice_ids contain only edifices from the commune" do
        access = build(:recenseur_access, recenseur:, commune:, edifice_ids: [edifice1.id, edifice2.id])
        expect(access).to be_valid
      end

      it "is invalid when edifice_ids contain edifices from other communes" do
        access = build(:recenseur_access, recenseur:, commune:, edifice_ids: [edifice1.id, other_edifice.id])
        expect(access).not_to be_valid
        expect(access.errors[:edifice_ids]).to include("contient des édifices non valides")
      end

      it "is valid when edifice_ids is empty" do
        access = build(:recenseur_access, recenseur:, commune:, all_edifices: true, edifice_ids: [])
        expect(access).to be_valid
      end
    end
  end

  describe "#edifice?" do
    let!(:edifice1) { create(:edifice, commune:) }
    let!(:edifice2) { create(:edifice, commune:) }
    let(:access) { create(:recenseur_access, recenseur:, commune:, all_edifices: false, edifice_ids: [edifice1.id]) }

    it "returns true for edifices in edifice_ids" do
      expect(access.edifice?(edifice1)).to be true
    end

    it "returns false for edifices not in edifice_ids" do
      expect(access.edifice?(edifice2)).to be false
    end
  end

  describe "#edifices" do
    let!(:edifice1) { create(:edifice, commune:) }
    let!(:edifice2) { create(:edifice, commune:) }

    context "when all_edifices is true" do
      let(:access) { create(:recenseur_access, recenseur:, commune:, all_edifices: true) }

      it "returns all edifices from the commune" do
        expect(access.edifices).to contain_exactly(edifice1, edifice2)
      end
    end

    context "when all_edifices is false and edifice_ids contains specific ids" do
      let(:access) { create(:recenseur_access, recenseur:, commune:, all_edifices: false, edifice_ids: [edifice1.id]) }

      it "returns only the specified edifices" do
        expect(access.edifices).to contain_exactly(edifice1)
      end
    end

    context "when edifice_ids is empty and all_edifices is false" do
      let(:access) { build(:recenseur_access, recenseur:, commune:, all_edifices: false, edifice_ids: []) }

      it "returns Edifice.none" do
        expect(access.edifices).to eq(Edifice.none)
      end
    end
  end
end
