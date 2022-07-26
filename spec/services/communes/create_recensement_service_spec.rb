# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength

RSpec.describe Communes::CreateRecensementService, type: :service do
  subject { Communes::CreateRecensementService.new(params:, objet:, user:).perform }

  context "success for first recensement" do
    let!(:commune) { create(:commune, status: "inactive") }
    let!(:objet) { create(:objet, commune:) }
    let!(:user) { create(:user, commune:) }

    let(:params) do
      {
        localisation: Recensement::LOCALISATION_EDIFICE_INITIAL,
        recensable: true,
        edifice_nom: nil,
        etat_sanitaire: Recensement::ETAT_BON,
        etat_sanitaire_edifice: Recensement::ETAT_MOYEN,
        securisation: Recensement::SECURISATION_CORRECTE,
        notes: "objet très doux",
        skip_photos: true
      }
    end

    before do
      expect(commune).to receive(:start!)
      expect(TriggerSibContactEventJob).to receive(:perform_async)
      expect(SendMattermostNotificationJob).to receive(:perform_async)
    end

    it "should work" do
      res = subject
      expect(res.success?).to be true
      # expect(res.recensement).to be_a?(Recensement)
      expect(res.recensement.persisted?).to be true
    end
  end

  context "success for successive recensement" do
    let!(:commune) { create(:commune, status: "started") }
    let!(:dossier) { create(:dossier, commune:, status: "construction") }
    before { commune.update!(dossier:) }
    let!(:objet) { create(:objet, commune:) }
    let!(:user) { create(:user, commune:) }

    let(:params) do
      {
        localisation: Recensement::LOCALISATION_EDIFICE_INITIAL,
        recensable: true,
        edifice_nom: nil,
        etat_sanitaire: Recensement::ETAT_BON,
        etat_sanitaire_edifice: Recensement::ETAT_MOYEN,
        securisation: Recensement::SECURISATION_CORRECTE,
        notes: "objet très doux",
        skip_photos: true
      }
    end

    before do
      expect(commune).not_to receive(:start!)
      expect(TriggerSibContactEventJob).not_to receive(:perform_async)
      expect(SendMattermostNotificationJob).to receive(:perform_async)
    end

    it "should work" do
      res = subject
      expect(res.success?).to be true
      # expect(res.recensement).to be_a?(Recensement)
      expect(res.recensement.persisted?).to be true
      expect(res.recensement.dossier).to eq dossier
    end
  end

  context "failure - wrong params" do
    let!(:commune) { create(:commune, status: "inactive") }
    let!(:objet) { create(:objet, commune:) }
    let!(:user) { create(:user, commune:) }

    let(:params) do
      {
        localisation: Recensement::LOCALISATION_EDIFICE_INITIAL,
        recensable: true,
        edifice_nom: nil,
        # etat_sanitaire: Recensement::ETAT_BON,
        etat_sanitaire_edifice: Recensement::ETAT_MOYEN,
        securisation: Recensement::SECURISATION_CORRECTE,
        notes: "objet très doux",
        skip_photos: true
      }
    end

    before do
      expect(commune).not_to receive(:start!)
      expect(TriggerSibContactEventJob).not_to receive(:perform_async)
      expect(SendMattermostNotificationJob).not_to receive(:perform_async)
    end

    it "should work" do
      res = subject
      expect(res.success?).to be false
      # expect(res.recensement).to be_a?(Recensement)
      expect(res.recensement.persisted?).to be false
      expect(res.recensement.errors.count).to be > 1
    end
  end
end
# rubocop:enable Metrics/BlockLength
