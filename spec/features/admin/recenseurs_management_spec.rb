# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin - Gestion des recenseurs", type: :feature, js: true do
  let(:admin) { create(:admin_user) }
  let(:drome) { create(:departement, code: "26", nom: "Drôme") }
  let(:rhone) { create(:departement, code: "69", nom: "Rhône") }
  let(:albon) { create(:commune, nom: "Albon", code_insee: "26002", departement: drome) }
  let(:lyon) { create(:commune, nom: "Lyon", code_insee: "69123", departement: rhone) }

  include ActiveJob::TestHelper

  before(:each) { login_as(admin, scope: :admin_user) }

  scenario "Un admin peut créer un nouveau recenseur" do
    visit admin_recenseurs_path
    expect(page).to have_text("Recenseurs")

    click_on "Créer un nouveau recenseur"
    fill_in "Email", with: "nouveau-recenseur@test.fr"
    fill_in "Nom", with: "Nouveau Recenseur"
    select "Autorisé à recenser", from: "Statut"
    click_on "Enregistrer"

    expect(page).to have_text("Recenseur créé avec succès")
    expect(page).to have_text("nouveau-recenseur@test.fr")
    expect(Recenseur.find_by(email: "nouveau-recenseur@test.fr")).to be_present
  end

  scenario "Un admin peut accorder l'accès d'un recenseur à une commune" do
    recenseur = create(:recenseur, email: "recenseur-multi@test.fr", status: :accepted)

    visit admin_recenseur_path(recenseur)
    expect(page).to have_text("recenseur-multi@test.fr")

    fill_in "Rechercher une commune", with: albon.nom
    click_on "Rechercher"
    expect(page).to have_text("Albon (26 - Drôme)")
    within(dom_id(albon)) do
      click_on "Ajouter l'accès à Albon (Drôme)"
    end

    expect(page).to have_button("Accès ajouté", disabled: true)
    access = RecenseurAccess.find_by(recenseur:, commune: albon)
    expect(access).to be_present
    expect(access.granted).to be_truthy

    fill_in "Rechercher une commune", with: lyon.nom
    click_on "Rechercher"
    expect(page).to have_text("Lyon (69 - Rhône)")
    within(dom_id(lyon)) do
      click_on "Ajouter l'accès à Lyon (Rhône)"
    end

    expect(page).to have_button("Accès ajouté", disabled: true)
    access2 = RecenseurAccess.find_by(recenseur:, commune: lyon)
    expect(access2).to be_present
    expect(access2.granted).to be_truthy

    perform_enqueued_jobs
    emails = ActionMailer::Base.deliveries.last(2)
    expect(emails.map(&:to).flatten).to include("recenseur-multi@test.fr")
  end

  scenario "Un admin peut supprimer l'accès d'un recenseur" do
    recenseur = create(:recenseur, email: "recenseur-acces@test.fr", status: :accepted)
    access = create(:recenseur_access, recenseur:, commune: albon, granted: true, notified: false)

    visit admin_recenseur_path(recenseur)
    expect(page).to have_text("Albon")
    uncheck "Albon (Drôme)"

    expect(page).not_to have_text("Albon")
    expect(RecenseurAccess.exists?(access.id)).to be_falsey

    perform_enqueued_jobs
    email = ActionMailer::Base.deliveries.last
    expect(email.to).to include("recenseur-acces@test.fr")
  end

  scenario "Un admin peut supprimer un recenseur" do
    recenseur = create(:recenseur, nom: "recenseur-suppression", email: "recenseur-suppression@test.fr")

    visit admin_recenseurs_path

    fill_in "Nom, email ou notes", with: recenseur.email
    click_on "Filtrer"
    expect(page).to have_text(recenseur.email)

    click_on recenseur.nom
    accept_confirm do
      click_on "Supprimer"
    end

    expect(page).to have_text("Recenseur supprimé")
    expect(Recenseur.exists?(email: recenseur.email)).to be_falsey
  end
end
