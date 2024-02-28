# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Bordereau::Pdf" do
  context "regular dossier" do
    let!(:departement) { create(:departement, code: "26", nom: "Drôme") }
    let!(:commune) { create(:commune, status: "completed", nom: "Albon", code_insee: "26002", departement:) }
    let!(:edifice) { create(:edifice, nom: "Eglise st Jean", commune:) }
    let!(:user) { create(:user, email: "mairie-albon@test.fr", commune:) }
    let!(:conservateur) do
      create(:conservateur,
             first_name: "Jean", last_name: "Lobo", email: "jeanne@culture.gouv.fr",
             departements: [departement])
    end
    let!(:dossier) do
      create(:dossier, :accepted, commune:, conservateur:, notes_conservateur: "Les photos sont superbes")
    end
    before { commune.update(dossier:) }
    let!(:objet_bouquet) do
      create(:objet, palissy_REF: "PM51001253", palissy_TICO: "Bouquet d'Autel", edifice:, commune:)
    end
    let!(:objet_ciboire) do
      create(:objet, palissy_REF: "PM51001254", palissy_TICO: "Ciboire des malades", edifice:, commune:)
    end
    let!(:recensement_bouquet) do
      create(
        :recensement,
        objet: objet_bouquet, user:, dossier:,
        etat_sanitaire: Recensement::ETAT_BON,
        analyse_etat_sanitaire: Recensement::ETAT_PERIL,
        securisation: Recensement::SECURISATION_CORRECTE,
        notes: "objet très doux",
        analyse_notes: "Ce bouquet va fâner !!!",
        analyse_fiches: [Recensement::ANALYSE_FICHE_ENTRETIEN_EDIFICES, Recensement::ANALYSE_FICHE_SECURISATION],
        analysed_at: 2.days.ago,
        conservateur:
      )
    end
    let!(:recensement_ciboire) do
      create(
        :recensement,
        objet: objet_ciboire, user:, dossier:,
        etat_sanitaire: Recensement::ETAT_BON,
        securisation: Recensement::SECURISATION_CORRECTE,
        notes: nil,
        analysed_at: 2.days.ago,
        conservateur:
      )
    end
    # TODO: add mocked photos

    it "does not raise" do
      expect { Bordereau::Pdf.new(dossier, edifice).build_prawn_doc }.not_to raise_error
    end
  end
end
