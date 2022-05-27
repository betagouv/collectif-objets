# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.feature "Conservateurs - Reject Dossier", type: :feature, js: true do
  let!(:conservateur) { create(:conservateur, email: "jeanne@culture.gouv.fr", departements: ["26"]) }
  let!(:commune) do
    create(:commune, nom: "Albon", code_insee: "26002", departement: "26", status: Commune::STATE_COMPLETED)
  end
  let!(:dossier) { create(:dossier, :submitted, commune:) }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", role: "mairie", commune:) }
  let!(:objet_bouquet) { create(:objet, palissy_DENO: "Bouquet d'Autel", palissy_EDIF: "Eglise st Jean", commune:) }
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
  let!(:objet_ciboire) { create(:objet, palissy_DENO: "Ciboire des malades", palissy_EDIF: "Musée", commune:) }
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
    expect(dbl).to receive(:dossier_rejected_email).and_return(double(deliver_later: true))
  end

  scenario "full" do
    login_as(conservateur, scope: :conservateur)
    visit "/conservateurs/departements"
    click_on "Drôme (26)"
    click_on "Albon"

    # override field on first recensement
    click_on "Bouquet d'Autel"
    etat_sanitaire_group = find("b", text: "Comment évaluez-vous l’état sanitaire de l’objet ?")
      .find(:xpath, "ancestor::div[contains(@class, 'attribute-group')]")
    within(etat_sanitaire_group) do
      click_on "Modifier"
      sleep 1
      select "En péril", from: "recensement[analyse_etat_sanitaire]"
    end
    click_on "Sauvegarder"

    click_on "Retour à la liste des recensements de la commune"

    click_on "Renvoyer le dossier à la commune …"
    fill_in "dossier[notes_conservateur]", with: "Veuillez renseigner les photos please"
    click_on "Photos floues"
    expect(find_field("dossier[notes_conservateur]").value).to \
      include("Une partie des photos que vous avez envoyées sont trop floues pour être acceptées")
    click_on "Renvoyer le dossier"
    expect(page).to have_content(/Dossier renvoyé à la commune/i)
  end
end
# rubocop:enable Metrics/BlockLength
