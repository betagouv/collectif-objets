# frozen_string_literal: true

require "rails_helper"

RSpec.describe Commune, type: :model do
  describe "#start!" do
    let!(:commune) { create(:commune, status: :inactive, dossier: nil) }
    it "change le statut de la commune et créé un dossier" do
      commune.start!
      expect(commune.status.to_sym).to eq :started
      expect(commune.dossier).to be_a Dossier
      expect(commune.dossier.status.to_sym).to eq :construction
    end
  end

  describe "#start! mais un problème se produit" do
    let!(:commune) { create(:commune, status: :inactive, dossier: nil) }
    before do
      def commune.aasm_before_start
        super
        raise StandardError
      end
    end

    it "annule tous les changements" do
      initial_dossier_count = Dossier.count
      expect { commune.start! }.to raise_exception StandardError
      expect(commune.reload.status.to_sym).to eq :inactive
      expect(commune.reload.dossier).to be_nil
      expect(Dossier.count).to eq initial_dossier_count
    end
  end

  describe "#start! mais la commune est déjà associée à un dossier" do
    let!(:commune) { create(:commune, status: :inactive) }
    let!(:dossier) { create(:dossier, commune:) }
    before { commune.update!(dossier:) }
    it "échoue et annule les changements" do
      initial_dossier_count = Dossier.count
      expect { commune.start! }.to(raise_error { AASM::InvalidTransition })
      expect(commune.reload.status.to_sym).to eq :inactive
      expect(commune.reload.dossier).to eq dossier
      expect(Dossier.count).to eq initial_dossier_count
    end
  end

  describe "#complete!" do
    let!(:commune) { create(:commune, status: :started) }
    let!(:dossier) { create(:dossier, commune:) }
    before { commune.update!(dossier:) }
    it "change le statut de la commune et du dossier" do
      commune.complete!
      expect(commune.reload.status.to_sym).to eq :completed
      expect(dossier.reload.status.to_sym).to eq :submitted
      expect(commune.reload.completed_at).to be_within(2.seconds).of(Time.zone.now)
    end
  end

  describe "#complete! mais dossier.submit! échoue" do
    let!(:commune) { create(:commune, status: :started) }
    let!(:dossier) { create(:dossier, commune:) }
    before { commune.update!(dossier:) }
    before { expect(dossier).to receive(:submit!).and_raise(AASM::InvalidTransition) }
    it "échoue et annule les changements" do
      expect { commune.complete! }.to(raise_error { AASM::InvalidTransition })
      expect(commune.reload.status.to_sym).to eq :started
      expect(dossier.reload.status.to_sym).to eq :construction
    end
  end

  describe "#return_to_started!" do
    let!(:commune) { create(:commune, status: :completed) }
    let!(:dossier) { create(:dossier, commune:, status: :submitted) }
    before { commune.update!(dossier:) }
    it "change le statut de la commune et du dossier" do
      commune.return_to_started!
      expect(commune.reload.status.to_sym).to eq :started
      expect(dossier.reload.status.to_sym).to eq :construction
    end
  end

  describe "#return_to_started! mais dossier.return_to_construction échoue" do
    let!(:commune) { create(:commune, status: :completed) }
    let!(:dossier) { create(:dossier, commune:, status: :submitted) }
    before { commune.update!(dossier:) }
    before { expect(dossier).to receive(:return_to_construction!).and_raise(AASM::InvalidTransition) }
    it "échoue et annule les changements" do
      expect { commune.return_to_started! }.to(raise_error { AASM::InvalidTransition })
      expect(commune.reload.status.to_sym).to eq :completed
      expect(dossier.reload.status.to_sym).to eq :submitted
    end
  end
end