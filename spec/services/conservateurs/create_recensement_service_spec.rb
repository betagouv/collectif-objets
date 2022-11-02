# frozen_string_literal: true

require "rails_helper"

RSpec.describe Conservateurs::CreateRecensementService, type: :service do
  let(:valid_params) do
    {
      localisation: Recensement::LOCALISATION_EDIFICE_INITIAL,
      recensable: true,
      edifice_nom: nil,
      etat_sanitaire: Recensement::ETAT_BON,
      etat_sanitaire_edifice: Recensement::ETAT_MOYEN,
      securisation: Recensement::SECURISATION_CORRECTE,
      notes: "objet très doux",
      confirmation_pas_de_photos: true,
      confirmation_sur_place: true
    }
  end

  context "first recensement in edifice" do
    let!(:commune) { create(:commune, status: "inactive") }
    let!(:edifice) { create(:edifice, commune:) }
    let!(:objet) { create(:objet, commune:, edifice:) }
    let!(:conservateur) { create(:conservateur) }
    subject(:service) { Conservateurs::CreateRecensementService.new(params: valid_params, objet:, conservateur:) }
    before { expect(SendMattermostNotificationJob).to receive(:perform_async) }

    it "should create recensement and dossier" do
      expect(Dossier.count).to eq 0
      expect(Recensement.count).to eq 0
      expect(commune).not_to receive(:start!)
      service.perform
      expect(Dossier.count).to eq 1
      expect(Recensement.count).to eq 1
      expect(service.success?).to be true
      expect(service.recensement.persisted?).to be true
      expect(service.recensement.conservateur).to eq conservateur
      expect(service.recensement.author).to eq conservateur
      expect(service.recensement.dossier.author_role).to eq "conservateur"
      expect(service.recensement.dossier.edifice).to eq edifice
    end
  end

  context "first recensement in edifice" do
    let!(:commune) { create(:commune, status: "inactive") }
    let!(:edifice) { create(:edifice, commune:) }
    let!(:objet) { create(:objet, commune:, edifice:) }
    let!(:conservateur) { create(:conservateur) }
    let!(:dossier) { create(:dossier, edifice:, commune:, conservateur:, author_role: "conservateur") }
    subject(:service) { Conservateurs::CreateRecensementService.new(params: valid_params, objet:, conservateur:) }
    before { expect(SendMattermostNotificationJob).to receive(:perform_async) }

    it "should work" do
      expect(Recensement.count).to eq 0
      expect(Dossier.count).to eq 1
      expect(commune).not_to receive(:start!)
      service.perform
      expect(service.success?).to be true
      expect(Recensement.count).to eq 1
      expect(Dossier.count).to eq 1
      expect(service.recensement.persisted?).to be true
      expect(service.recensement.conservateur).to eq conservateur
      expect(service.recensement.author).to eq conservateur
      expect(service.recensement.dossier).to eq dossier
    end
  end
end
