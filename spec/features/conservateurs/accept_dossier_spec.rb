# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Conservateurs - Accept Dossier", type: :feature, js: true do
  let!(:departement) { create(:departement, code: "26", nom: "Drôme") }
  let!(:conservateur) { create(:conservateur, email: "jeanne@culture.gouv.fr", departements: [departement]) }
  let!(:commune) do
    create(:commune, nom: "Albon", code_insee: "26002", departement:, status: Commune::STATE_COMPLETED)
  end
  let!(:edifice) { create(:edifice, code_insee: "26002", nom: "Église St Jean", slug: "eglise-st-jean") }
  let!(:dossier) { create(:dossier, :submitted, commune:) }
  before { commune.update!(dossier:) }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", role: "mairie", commune:) }
  let!(:objet_bouquet) { create(:objet, palissy_TICO: "Bouquet d'Autel", edifice:, commune:) }
  let!(:recensement_bouquet) do
    create(
      :recensement,
      objet: objet_bouquet, user:, dossier:,
      etat_sanitaire: Recensement::ETAT_BON,
      etat_sanitaire_edifice: Recensement::ETAT_MOYEN,
      securisation: Recensement::SECURISATION_CORRECTE,
      notes: "objet très doux"
    )
  end
  let!(:objet_ciboire) { create(:objet, palissy_TICO: "Ciboire des malades", commune:, edifice:) }
  let!(:recensement_ciboire) do
    create(
      :recensement,
      objet: objet_ciboire, user:, dossier:,
      etat_sanitaire: Recensement::ETAT_BON,
      etat_sanitaire_edifice: Recensement::ETAT_MOYEN,
      securisation: Recensement::SECURISATION_CORRECTE,
      notes: nil
    )
  end

  scenario "full" do
    login_as(conservateur, scope: :conservateur)
    visit "/conservateurs/departements"
    expect(page).to have_text("Drôme")

    click_on "26 - Drôme"
    expect(page).to have_text("Albon")
    click_on "Albon"

    expect(page).to have_text("Bouquet d'Autel")
    expect(page).to have_text("Ciboire des malades")

    # analyse first recensement
    click_on "Bouquet d'Autel"
    etat_sanitaire_group = find("b", text: "Dans quel état est l’objet ?")
      .find(:xpath, "ancestor::div[contains(@class, 'attribute-group')]")
    within(etat_sanitaire_group) do
      click_on "Modifier"
      select "L'objet est en péril", from: "recensement[analyse_etat_sanitaire]"
    end
    find("label", text: "Entretenir").click
    find("label", text: "Comment porter plainte ?").click
    fill_in "recensement[analyse_notes]", with: "Est-ce qu'il est le pepito bleu?"

    click_on "Sauvegarder"
    expect(page).to have_text("Votre analyse a bien été sauvegardée")

    # analyse second recensement
    click_on "Ciboire des malades"
    securisation_group = find("b", text: "Est-il facile de voler cet objet ?")
      .find(:xpath, "ancestor::div[contains(@class, 'attribute-group')]")
    within(securisation_group) do
      click_on "Modifier"
      select "L’objet est facile à voler", from: "recensement[analyse_securisation]"
    end

    click_on "Sauvegarder"
    expect(page).to have_text("Vous avez analysé tous les recensements de Albon")

    # envoi rapport
    click_on "Finaliser le rapport …"
    bouquet_row = find_link("Bouquet d'Autel").find(:xpath, "ancestor::tr")
    expect(bouquet_row).to have_text(/fiche vol/i)
    expect(bouquet_row).to have_text(/entretenir/i)
    expect(bouquet_row.all("td")[1]).to have_text(/Bon/i)
    expect(bouquet_row.all("td")[1]).to have_text(/L'objet est en péril/i)
    ciboire_row = find_link("Ciboire des malades").find(:xpath, "ancestor::tr")
    expect(ciboire_row).not_to have_text(/fiche vol/i)
    expect(ciboire_row).not_to have_text(/Entretenir/i)
    fill_in("dossier[notes_conservateur]", with: "Merci pour ce joli dossier")
    click_on "Mettre à jour mes retours"
    click_on "Envoyer le rapport à la commune"

    # visualisation rapport
    expect(page).to have_text(/Rapport envoyé à la commune/i)
    click_on "Voir le rapport"
    expect(page).to have_text(/Ciboire des malades/i)
    expect(page).to have_text(/Merci pour ce joli dossier/i)
    expect(page).to have_text(/pepito bleu/i)
  end
end
