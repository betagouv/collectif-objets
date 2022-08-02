# frozen_string_literal: true

# rubocop: disable Metrics/BlockLength

require "rails_helper"

RSpec.feature "Communes - Read rapport", type: :feature, js: true do
  let!(:commune) { create(:commune, status: "completed", nom: "Albon", code_insee: "26002", departement: "26") }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", role: "mairie", commune:, magic_token: "magiemagie") }
  let!(:conservateur) do
    create(:conservateur, first_name: "Jean", last_name: "Lobo", email: "jeanne@culture.gouv.fr", departements: ["26"])
  end
  let!(:dossier) do
    create(:dossier, :accepted, commune:, conservateur:, notes_conservateur: "Les photos sont superbes")
  end
  before { commune.update(dossier:) }
  let!(:objet_bouquet) do
    create(:objet, palissy_REF: "PM51001253", palissy_DENO: "Bouquet d'Autel", palissy_EDIF: "Eglise st Jean", commune:)
  end
  let!(:objet_ciboire) do
    create(:objet, palissy_REF: "PM51001254", palissy_DENO: "Ciboire des malades", palissy_EDIF: "Musée", commune:)
  end
  let!(:recensement_bouquet) do
    create(
      :recensement,
      objet: objet_bouquet, user:, dossier:,
      etat_sanitaire: Recensement::ETAT_BON,
      analyse_etat_sanitaire: Recensement::ETAT_PERIL,
      etat_sanitaire_edifice: Recensement::ETAT_MOYEN,
      securisation: Recensement::SECURISATION_CORRECTE,
      notes: "objet très doux",
      analyse_notes: "Ce bouquet va fâner !!!",
      analyse_fiches: [Recensement::ANALYSE_FICHE_NUISIBLES, Recensement::ANALYSE_FICHE_SECURISATION],
      analyse_actions: [Recensement::ANALYSE_ACTION_IDENTIFIER],
      analysed_at: 2.days.ago
    )
  end
  let!(:recensement_ciboire) do
    create(
      :recensement,
      objet: objet_ciboire, user:, dossier:,
      etat_sanitaire: Recensement::ETAT_BON,
      etat_sanitaire_edifice: Recensement::ETAT_MOYEN,
      securisation: Recensement::SECURISATION_CORRECTE,
      notes: nil,
      analysed_at: 2.days.ago
    )
  end

  scenario "read rapport for accepted dossier" do
    login_as(user, scope: :user)
    visit "/"
    within("header") { click_on "Voir les objets de Albon" }
    expect(page).to have_text(/Dossier accepté par le conservateur/i)
    click_on "Voir le rapport"
    expect(page).to have_text(/Jean Lobo/i)
    expect(page).to have_text(/jeanne@culture.gouv.fr/i)
    expect(page).to have_text(/Les photos sont superbes/i)
    within(find("#PM51001253")) do
      expect(page).to have_text(/Bouquet d'autel/i)
      expect(page).to have_text(/objet très doux/i)
      expect(page).to have_text(/ce bouquet va fâner/i)
      strikethrough = find(".co-text--strikethrough", text: /L'objet est en bon état/i)
      expect(strikethrough).to be_truthy
      expect(page).to have_text(/L'objet est en péril/i)
      expect(page).to have_text(/fiche securisation/i)
      expect(page).to have_text(/fiche nuisibles/i)
      expect(page).not_to have_text(/identifier/i) # actions visibles seulement par les conservateurs
    end
    within(find("#PM51001254")) do
      expect(page).to have_text(/Ciboire des malades/i)
      expect(page).not_to have_text(/Bouquet d'autel/i)
      expect(page).to have_text(/Aucune photo de recensement/i)
      expect(page).to have_text(/Musée/i)
      expect(page).not_to have_text(/L'objet est en péril/i)
      expect(page).to have_text(/L'objet est en bon état/i)
      expect(page).to have_text(/Aucun commentaire/i)
    end
  end
end
# rubocop: enable Metrics/BlockLength
