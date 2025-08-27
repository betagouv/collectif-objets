# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecenseurAccess, type: :model do
  let(:access) { build(:recenseur_access) }

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
      let(:recenseur) { create(:recenseur) }
      let(:commune) { create(:commune) }

      context "when access is initially granted and notified" do
        let(:access) { create(:recenseur_access, recenseur:, commune:, granted: true, notified: true) }

        it "resets notified to false when access is revoked" do
          expect { access.update!(granted: false) }.to change { access.notified }.from(true).to(false)
        end

        it "resets notified to false when access becomes pending" do
          expect { access.update!(granted: nil) }.to change { access.notified }.from(true).to(false)
        end

        it "does not reset notified when granted status does not change" do
          expect { access.update!(commune: create(:commune)) }.not_to(change { access.notified })
        end
      end

      context "when access is initially revoked and notified" do
        let(:access) { create(:recenseur_access, recenseur:, commune:, granted: false, notified: true) }

        it "resets notified to false when access is granted" do
          expect { access.update!(granted: true) }.to change { access.notified }.from(true).to(false)
        end
      end

      context "when access is initially pending and notified" do
        let(:access) { create(:recenseur_access, recenseur:, commune:, granted: nil, notified: true) }

        it "resets notified to false when access is granted" do
          expect { access.update!(granted: true) }.to change { access.notified }.from(true).to(false)
        end

        it "resets notified to false when access is revoked" do
          expect { access.update!(granted: false) }.to change { access.notified }.from(true).to(false)
        end
      end
    end
  end
end
