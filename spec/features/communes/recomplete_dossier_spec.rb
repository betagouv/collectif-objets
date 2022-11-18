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
      etat_sanitaire_edifice: Recensement::ETAT_MOYEN,
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
      etat_sanitaire_edifice: Recensement::ETAT_MOYEN,
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
    click_on "modifier le recensement"
    expect(page).to have_field("recensement[etat_sanitaire_edifice]", disabled: false, visible: false)
    expect(page).to have_field("recensement[analyse_etat_sanitaire]", disabled: true, visible: false)
    etat_sanitaire_group = all(:xpath, "//input[@name='recensement[analyse_etat_sanitaire]']", visible: false)[0]
      .find(:xpath, "ancestor::div[@class='fr-form-group']")
    expect(etat_sanitaire_group).to \
      have_content "Cette évaluation a été modifiée par le conservateur, vous ne pouvez pas la modifier"
    within("[data-recensement-target=securisation]") do
      find("label", text: "L’objet est facile à voler").click
    end
    click_on "Enregistrer ce recensement"
    click_on "Renvoyer le dossier…"
    expect(find_link("Bouquet d'Autel").find(:xpath, "ancestor::tr")).to have_text(/facile à voler/i)
    fill_in "commune[dossier_attributes][notes_commune]", with: "Voila ca devrait aller"
    click_on "Renvoyer le dossier au conservateur"
  end
end
