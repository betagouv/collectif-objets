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
    describe "#filter_invalid_edifice_ids" do
      let!(:edifice) { create(:edifice, commune:) }
      let(:other_edifice) { create(:edifice) }

      it "removes edifice ids that don't belong to the commune" do
        # Force reload to ensure association is fresh after edifice creation
        commune.reload
        access = build(:recenseur_access, recenseur:, commune:, edifice_ids: [edifice.id, other_edifice.id])
        access.valid?
        expect(access.edifice_ids).to contain_exactly(edifice.id)
      end
    end

    describe "#ensure_consistency" do
      subject(:ensure_consistency) { access.send(:ensure_consistency) }

      let(:access) { create(:recenseur_access, recenseur:, commune:, granted:, all_edifices:, edifice_ids:) }
      let(:granted) { true }
      let(:all_edifices) { true }
      let(:edifice_ids) { [] }

      context "when granted becomes true" do
        let(:granted) { true }

        context "and edifice_ids is empty" do
          let(:edifice_ids) { [] }

          it "set all_edifices to true and edifice_ids = commune.edifice_ids" do
            access.update!(granted: true)
            expect(access.all_edifices).to be true
            expect(access.edifice_ids).to eq(commune.edifice_ids)
          end
        end

        context "and all edifices are selected" do
          let(:edifice_ids) { commune.edifice_ids }

          it "set all_edifices to true and edifice_ids = commune.edifice_ids" do
            access.update!(granted: true)
            expect(access.all_edifices).to be true
            expect(access.edifice_ids).to eq(commune.edifice_ids)
          end
        end
      end

      context "when all_edifices" do
        let!(:edifice1) { create(:edifice, commune:) }
        let!(:edifice2) { create(:edifice, commune:) }

        context "becomes true" do
          let(:all_edifices) { false }

          it "sets edifice_ids = commune.edifice_ids" do
            access.update!(all_edifices: true)
            expect(access.edifice_ids).to eq(commune.edifice_ids)
          end
        end

        context "becomes false" do
          let(:all_edifices) { true }

          it "sets edifice_ids = []" do
            access.update!(all_edifices: false)
            expect(access.edifice_ids).to eq([])
          end
        end
      end

      context "when edifice_ids" do
        let!(:edifice1) { create(:edifice, commune:) }
        let!(:edifice2) { create(:edifice, commune:) }

        context "becomes []" do
          let(:all_edifices) { true }
          let(:edifice_ids) do
            commune.reload
            commune.edifice_ids
          end

          it "sets all_edifices = false" do
            access.update!(edifice_ids: [])
            expect(access.all_edifices).to be false
          end
        end

        context "becomes commune.edifice_ids" do
          let(:edifice_ids) { [] }

          it "sets all_edifices = true" do
            access.update!(edifice_ids: commune.edifice_ids)
            expect(access.all_edifices).to be true
          end
        end
      end
    end

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
  end

  describe "validations" do
    let(:edifice1) { create(:edifice, commune:) }
    let(:edifice2) { create(:edifice, commune:) }
    let(:other_edifice) { create(:edifice) }

    it "is always valid due to ensure_consistency making automatic adjustments" do
      access = build(:recenseur_access, recenseur:, commune:, edifice_ids: [])
      access.valid? # Trigger validations/callbacks
      expect(access).to be_valid
      expect(access.all_edifices).to be true # Automatically adjusted
    end

    it "is valid when all_edifices is false and edifice_ids contains valid ids" do
      access = build(:recenseur_access, recenseur:, commune:, all_edifices: false, edifice_ids: [edifice1.id])
      expect(access).to be_valid
    end
  end

  describe "#edifice?" do
    let!(:edifice1) { create(:edifice, commune:) }
    let!(:edifice2) { create(:edifice, commune:) }
    let(:access) do
      commune.reload
      create(:recenseur_access, recenseur:, commune:, all_edifices: false, edifice_ids: [edifice1.id])
    end

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
      let(:access) do
        commune.reload
        create(:recenseur_access, recenseur:, commune:, all_edifices: true)
      end

      it "returns all edifices from the commune" do
        expect(access.edifices).to contain_exactly(edifice1, edifice2)
      end
    end

    context "when all_edifices is false and edifice_ids contains specific ids" do
      let(:access) do
        commune.reload
        create(:recenseur_access, recenseur:, commune:, all_edifices: false, edifice_ids: [edifice1.id])
      end

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
