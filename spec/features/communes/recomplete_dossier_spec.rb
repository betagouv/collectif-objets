# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Communes - recomplete dossier", type: :feature, js: true do
  let!(:departement) { create(:departement, code: "26", nom: "Drôme") }
  let!(:commune) { create(:commune, status: "completed", nom: "Albon", code_insee: "26002", departement:) }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", role: "mairie", commune:, magic_token: "magiemagie") }
  let!(:conservateur) do
    create(:conservateur,
           first_name: "Jean", last_name: "Lobo", email: "jeanne@culture.gouv.fr",
           departements: [departement])
  end
  let!(:dossier) do
    create(:dossier, :rejected, commune:, conservateur:, notes_conservateur: "Veuillez prendre de meilleures photos")
  end
  before { commune.update!(dossier:) }
  let!(:objet_bouquet) { create(:objet, palissy_TICO: "Bouquet d'Autel", palissy_EDIF: "Eglise st Jean", commune:) }
  let!(:objet_ciboire) { create(:objet, palissy_TICO: "Ciboire des malades", palissy_EDIF: "Musée", commune:) }
  let!(:recensement_bouquet) do
    create(
      :recensement,
      objet: objet_bouquet, user:, dossier:,
      etat_sanitaire: Recensement::ETAT_BON,
      analyse_etat_sanitaire: Recensement::ETAT_PERIL,
      securisation: Recensement::SECURISATION_CORRECTE,
      notes: "objet très doux",
      analyse_notes: "Ce bouquet va fâner !!!",
      analysed_at: 2.days.ago,
      conservateur:
    )
  end
  let!(:objet_ciboire) { create(:objet, palissy_TICO: "Ciboire des malades", palissy_EDIF: "Musée", commune:) }
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

  before do
    dbl = instance_double(ConservateurMailer)
    expect(ConservateurMailer).to receive(:with).and_return(dbl)
    expect(dbl).to receive(:commune_recompleted_email).and_return(double(deliver_later: true))
  end

  scenario "recomplete and resubmit rejected dossier" do
    login_as(user, scope: :user)
    visit "/"
    within("header") { click_on "Voir les objets de Albon" }
    expect(page).to have_text(/Dossier renvoyé par le conservateur/i)
    expect(page).to have_text(/Jean Lobo/i)
    expect(page).to have_text("Veuillez prendre de meilleures photos")
    click_on "Bouquet d'Autel"
    click_on "Modifier le recensement"
    expect(page).to have_text("Récapitulatif")
    section_analyse_notes = find("section", text: "Commentaires du conservateur")
    expect(section_analyse_notes).to have_text("Ce bouquet va fâner !!!")
    section_etat = find("section", text: "Quel est l’état de l’objet ?")
    expect(section_etat).to \
      have_text "Cette évaluation a été modifiée par le conservateur, vous ne pouvez pas la modifier"
    section_securisation = find("section", text: "L’objet est-il en sécurité ?")
    section_securisation.find('button[aria-label="Modifier la réponse"]').click
    question_etat = find(".fr-form-group", text: "Quel est l’état actuel de l’objet ?")
    question_etat.find_all("input", visible: false).each { expect(_1.disabled?) }
    find("label", text: "L’objet est facile à voler").click
    click_on "Passer à l’étape suivante"
    sleep(0.2)
    click_on "Passer à l’étape suivante"
    click_on "Valider le recensement de cet objet"
    click_on "Renvoyer le dossier…"
    expect(find_link("Bouquet d'Autel").find(:xpath, "ancestor::tr")).to have_text(/facile à voler/i)
    fill_in "dossier_recompletion[notes_commune]", with: "Voila ca devrait aller"
    click_on "Renvoyer le dossier au conservateur"
  end
end
