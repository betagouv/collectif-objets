# frozen_string_literal: true

require "rails_helper"

RSpec.describe Communes::CreateRecensementService, type: :service do
  subject { Communes::CreateRecensementService.new(recensement).perform }

  context "success for first recensement" do
    let!(:commune) { create(:commune, status: "inactive") }
    let!(:objet) { create(:objet, commune:) }
    let!(:user) { create(:user, commune:) }

    let(:recensement) do
      Recensement.new(
        objet:,
        user:,
        confirmation_sur_place: true,
        localisation: Recensement::LOCALISATION_EDIFICE_INITIAL,
        recensable: true,
        edifice_nom: nil,
        etat_sanitaire: Recensement::ETAT_BON,
        securisation: Recensement::SECURISATION_CORRECTE,
        notes: "objet très doux"
      )
    end

    before do
      expect(commune).to receive(:start!).and_return(true)
      expect(SendMattermostNotificationJob).to receive(:perform_async)
    end

    it "should work" do
      res = subject
      expect(res.success?).to be true
      # expect(recensement).to be_a?(Recensement)
      expect(recensement.persisted?).to be true
    end
  end

  context "success for successive recensement" do
    let!(:commune) { create(:commune, status: "started") }
    let!(:dossier) { create(:dossier, commune:, status: "construction") }
    before { commune.update!(dossier:) }
    let!(:objet) { create(:objet, commune:) }
    let!(:user) { create(:user, commune:) }

    let(:recensement) do
      Recensement.new(
        objet:,
        user:,
        confirmation_sur_place: true,
        localisation: Recensement::LOCALISATION_EDIFICE_INITIAL,
        recensable: true,
        edifice_nom: nil,
        etat_sanitaire: Recensement::ETAT_BON,
        securisation: Recensement::SECURISATION_CORRECTE,
        notes: "objet très doux"
      )
    end

    before do
      expect(commune).not_to receive(:start!)
      expect(SendMattermostNotificationJob).to receive(:perform_async)
    end

    it "should work" do
      res = subject
      expect(res.success?).to be true
      # expect(recensement).to be_a?(Recensement)
      expect(recensement.persisted?).to be true
      expect(recensement.dossier).to eq dossier
    end
  end

  context "failure - wrong params" do
    let!(:commune) { create(:commune, status: "inactive") }
    let!(:objet) { create(:objet, commune:) }
    let!(:user) { create(:user, commune:) }

    let(:recensement) do
      Recensement.new(
        objet:,
        user:,
        localisation: Recensement::LOCALISATION_EDIFICE_INITIAL,
        recensable: true,
        edifice_nom: nil,
        # etat_sanitaire: Recensement::ETAT_BON,
        securisation: Recensement::SECURISATION_CORRECTE,
        notes: "objet très doux"
      )
    end

    before do
      expect(commune).not_to receive(:start!)
      expect(SendMattermostNotificationJob).not_to receive(:perform_async)
    end

    it "should work" do
      res = subject
      expect(res.success?).to be false
      # expect(recensement).to be_a?(Recensement)
      expect(recensement.persisted?).to be false
      expect(recensement.errors.count).to be > 1
    end
  end
end
