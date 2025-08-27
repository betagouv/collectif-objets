# frozen_string_literal: true

require "rails_helper"

RSpec.describe Recenseur, type: :model do
  describe "factory" do
    let(:recenseur) { build(:recenseur) }
    subject { recenseur.valid? }
    it { should be true }
  end

  describe "associations" do
    let(:recenseur) { create(:recenseur, status: :accepted) }
    let(:commune1) { create(:commune) }
    let(:commune2) { create(:commune) }

    it "has new_accesses association for newly granted accesses" do
      granted_access = create(:recenseur_access, :newly_granted, recenseur:, commune: commune1)
      _old_access = create(:recenseur_access, recenseur:, commune: commune2, granted: true, notified: true)

      expect(recenseur.new_accesses).to contain_exactly(granted_access)
    end

    it "has revoked_accesses association for newly revoked accesses" do
      revoked_access = create(:recenseur_access, :newly_revoked, recenseur:, commune: commune1)
      _old_access = create(:recenseur_access, recenseur:, commune: commune2, granted: false, notified: true)

      expect(recenseur.revoked_accesses).to contain_exactly(revoked_access)
    end

    it "has revoked_communes association" do
      create(:recenseur_access, :newly_revoked, recenseur:, commune: commune1)

      expect(recenseur.revoked_communes).to contain_exactly(commune1)
    end
  end

  describe "#notify_access_granted?" do
    let(:recenseur) { create(:recenseur, status:) }
    let(:commune) { create(:commune) }

    context "with accepted recenseur" do
      let(:status) { :accepted }

      context "with newly granted accesses" do
        before do
          create(:recenseur_access, :newly_granted, recenseur:, commune:)
        end

        it "returns true" do
          expect(recenseur.notify_access_granted?).to be true
        end
      end

      context "without newly granted accesses" do
        it "returns false" do
          expect(recenseur.notify_access_granted?).to be false
        end
      end
    end

    context "with rejected recenseur" do
      let(:status) { :rejected }

      before do
        create(:recenseur_access, :newly_granted, recenseur:, commune:)
      end

      it "returns false" do
        expect(recenseur.notify_access_granted?).to be false
      end
    end

    context "with pending recenseur" do
      let(:status) { :pending }

      before do
        create(:recenseur_access, :newly_granted, recenseur:, commune:)
      end

      it "returns false" do
        expect(recenseur.notify_access_granted?).to be false
      end
    end
  end

  describe "#notify_access_revoked?" do
    let(:recenseur) { create(:recenseur, status:) }
    let(:commune) { create(:commune) }

    context "with accepted recenseur" do
      let(:status) { :accepted }

      context "with newly revoked accesses" do
        before do
          create(:recenseur_access, :newly_revoked, recenseur:, commune:)
        end

        it "returns true" do
          expect(recenseur.notify_access_revoked?).to be true
        end
      end

      context "without newly revoked accesses" do
        it "returns false" do
          expect(recenseur.notify_access_revoked?).to be false
        end
      end
    end

    context "with rejected recenseur" do
      let(:status) { :rejected }

      before do
        create(:recenseur_access, :newly_revoked, recenseur:, commune:)
      end

      it "returns false" do
        expect(recenseur.notify_access_revoked?).to be false
      end
    end

    context "with pending recenseur" do
      let(:status) { :pending }

      before do
        create(:recenseur_access, :newly_revoked, recenseur:, commune:)
      end

      it "returns false" do
        expect(recenseur.notify_access_revoked?).to be false
      end
    end
  end

  describe "integration: access change notifications" do
    let(:recenseur) { create(:recenseur, status: :accepted) }
    let(:commune) { create(:commune) }

    context "when access transitions from granted to revoked" do
      it "properly tracks the notification state" do
        # Create initially granted access
        access = create(:recenseur_access, recenseur:, commune:, granted: true, notified: false)

        # Initially should be in new_accesses
        expect(recenseur.new_accesses).to include(access)
        expect(recenseur.revoked_accesses).not_to include(access)
        expect(recenseur.notify_access_granted?).to be true
        expect(recenseur.notify_access_revoked?).to be false

        # Simulate notification sent (mark as notified)
        access.update!(notified: true)
        expect(recenseur.notify_access_granted?).to be false

        # Now revoke the access - should reset notified flag
        access.update!(granted: false)

        # Reload associations to reflect changes
        recenseur.reload

        # Should now be in revoked_accesses and trigger revocation notification
        expect(recenseur.new_accesses).not_to include(access)
        expect(recenseur.revoked_accesses).to include(access)
        expect(recenseur.notify_access_granted?).to be false
        expect(recenseur.notify_access_revoked?).to be true

        # After revocation notification sent
        access.update!(notified: true)
        expect(recenseur.notify_access_revoked?).to be false
      end
    end
  end
end
