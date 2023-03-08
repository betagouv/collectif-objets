# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Conservateurs - Reject Dossier", type: :feature, js: true do
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
      securisation: Recensement::SECURISATION_CORRECTE,
      notes: "objet très doux"
    )
  end
  let!(:objet_ciboire) { create(:objet, palissy_TICO: "Ciboire des malades", edifice:, commune:) }
  let!(:recensement_ciboire) do
    create(
      :recensement,
      objet: objet_ciboire, user:, dossier:,
      etat_sanitaire: Recensement::ETAT_BON,
      securisation: Recensement::SECURISATION_CORRECTE,
      notes: nil
    )
  end

  scenario "full" do
    login_as(conservateur, scope: :conservateur)
    visit "/conservateurs/departements"
    click_on "26 - Drôme"
    click_on "Albon"

    # override field on first recensement
    click_on "Bouquet d'Autel"
    etat_sanitaire_group = find("div", text: /État sanitaire de l’objet/, class: "co-text--bold")
      .find(:xpath, "ancestor::div[contains(@class, 'attribute-group')]")
    within(etat_sanitaire_group) do
      click_on "Modifier"
      expect(etat_sanitaire_group).to have_selector(
        "select[name=\"recensement[analyse_etat_sanitaire]\"]",
        visible: true
      )
      select "L’objet est en péril", from: "recensement[analyse_etat_sanitaire]"
    end
    click_on "Sauvegarder"

    click_on "Retour à la liste des recensements de la commune"

    click_on "Renvoyer le dossier à la commune …"
    fill_in "dossier[notes_conservateur]", with: "Veuillez renseigner les photos please"
    click_on "Photos floues"
    expect(find_field("dossier[notes_conservateur]").value).to \
      include("Une partie des photos que vous avez envoyées sont trop floues")
    click_on "Préparer le mail de renvoi"
    iframe = find("iframe.co-mail-preview-iframe")
    within_frame(iframe) do
      expect(page).to have_content(/Monsieur le Maire/i)
    end
    click_on "Renvoyer le dossier"
    expect(page).to have_content(/Dossier renvoyé à la commune/i)
  end
end
