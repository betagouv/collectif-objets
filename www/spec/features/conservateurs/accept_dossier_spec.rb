# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.feature "Conservateurs - Accept Dossier", type: :feature, js: true do
  let!(:conservateur) { create(:conservateur, email: "jeanne@culture.gouv.fr", departements: ["26"]) }
  let!(:commune) do
    create(:commune, nom: "Albon", code_insee: "26002", departement: "26", status: Commune::STATE_COMPLETED)
  end
  let!(:dossier) { create(:dossier, :submitted, commune:) }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", role: "mairie", commune:) }
  let!(:objet_bouquet) { create(:objet, nom: "Bouquet d'Autel", edifice_nom: "Eglise st Jean", commune:) }
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
  let!(:objet_ciboire) { create(:objet, nom: "Ciboire des malades", edifice_nom: "Musée", commune:) }
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

  before do
    dbl = instance_double(UserMailer)
    expect(UserMailer).to receive(:with).and_return(dbl)
    expect(dbl).to receive(:dossier_accepted_email).and_return(double(deliver_now: true))
  end

  scenario "full" do
    login_as(conservateur, scope: :conservateur)
    visit "/conservateurs/departements"
    expect(page).to have_text("Drôme")

    click_on "Drôme (26)"
    expect(page).to have_text("Albon")
    click_on "Albon"

    expect(page).to have_text("Bouquet d'Autel")
    expect(page).to have_text("Ciboire des malades")

    # mark as prioritaire and come back to list
    click_on "Bouquet d'Autel"
    click_on "Marquer comme prioritaire"
    expect(page).to have_text("PRIORITAIRE")

    click_on "Albon"
    expect(recensement_bouquet.reload.analyse_prioritaire?).to be true
    card_autel = find_link("Bouquet d'Autel").find(:xpath, "ancestor::div[contains(@class, 'fr-card ')]")
    expect(card_autel).to have_text("PRIORITAIRE")

    # analyse first recensement
    click_on "Bouquet d'Autel"
    etat_sanitaire_group = find("b", text: "Comment évaluez-vous l’état sanitaire de l’objet ?")
      .find(:xpath, "ancestor::div[contains(@class, 'attribute-group')]")
    within(etat_sanitaire_group) do
      click_on "Modifier"
      select "En péril", from: "recensement[analyse_etat_sanitaire]"
    end
    find("label", text: "Entretenir").click
    find("label", text: "Comment porter plainte ?").click
    fill_in "recensement[analyse_notes]", with: "Est-ce qu'il est le pepito bleu?"

    click_on "Sauvegarder"
    expect(page).to have_text("Votre analyse a bien été sauvegardée")

    # analyse second recensement
    click_on "Ciboire des malades"
    securisation_group = find("b", text: "L’objet est-il en sécurité ?")
      .find(:xpath, "ancestor::div[contains(@class, 'attribute-group')]")
    within(securisation_group) do
      click_on "Modifier"
      select "Non, il peut être emporté facilement", from: "recensement[analyse_securisation]"
    end

    click_on "Sauvegarder"
    expect(page).to have_text("Vous avez analysé tous les recensements de Albon")

    # envoi rapport
    click_on "Envoyer le rapport …"
    bouquet_row = find_link("Bouquet d'Autel").find(:xpath, "ancestor::tr")
    expect(bouquet_row).to have_text(/comment porter plainte \?/i)
    expect(bouquet_row).to have_text(/entretenir/i)
    expect(bouquet_row.all("td")[1]).to have_text(/Bon/i)
    expect(bouquet_row.all("td")[1]).to have_text(/En péril/i)
    ciboire_row = find_link("Ciboire des malades").find(:xpath, "ancestor::tr")
    expect(ciboire_row).not_to have_text(/Comment porter plainte ?/i)
    expect(ciboire_row).not_to have_text(/Entretenir/i)
    fill_in("dossier[notes_conservateur]", with: "Merci pour ce joli dossier")
    click_on "Mettre à jour le rapport PDF"
    sleep 1
    click_on "Envoyer le rapport à la commune"
  end
end
# rubocop:enable Metrics/BlockLength
