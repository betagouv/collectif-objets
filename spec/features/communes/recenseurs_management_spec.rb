# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Communes - Gestion des recenseurs", type: :feature, js: true do
  let(:departement) { create(:departement, code: "26", nom: "Drôme") }
  let(:commune) { create(:commune, nom: "Albon", code_insee: "26002", departement:) }
  let(:user) { create(:user, email: "mairie-albon@test.fr", commune:) }

  include ActiveJob::TestHelper

  before(:each) do
    login_as(user, scope: :user)
    visit "/"
  end

  scenario "l'accès pour un recenseur peut être demandé" do
    click_link "Recenseurs"
    expect(page).to have_text("Recenseurs de Albon")
    expect(page).to be_axe_clean

    # Demande d'accès pour un nouveau recenseur
    fill_in "Email", with: "nouveau-recenseur@test.fr"
    click_button "Demander l'accès"

    # Vérification que la demande a été enregistrée
    expect(page).to have_text("nouveau-recenseur@test.fr")
    expect(page).to have_text("En attente")
    expect(page).to have_button("Révoquer l'accès")

    # Vérification en base de données
    access = RecenseurAccess.last
    expect(access.commune).to eq(commune)
    expect(access.recenseur.email).to eq("nouveau-recenseur@test.fr")
    expect(access.granted).to be_falsey
  end

  scenario "l'accès d'un recenseur peut être révoqué" do
    recenseur = create(:recenseur, email: "recenseur-existant@test.fr")
    access = create(:recenseur_access, recenseur:, commune:)

    click_link "Recenseurs"

    # Vérification que le recenseur est présent
    expect(page).to have_text("recenseur-existant@test.fr")
    expect(page).to have_text("En attente")

    # Révoquer l'accès
    accept_confirm do
      click_button "Révoquer l'accès"
    end
    expect(page).to have_text("aucun recenseur")
    expect(RecenseurAccess.exists?(id: access.id)).to be_falsey # L'accès a été supprimé
  end

  scenario "les recenseurs autorisés et en attente sont listés" do
    recenseur_autorise = create(:recenseur, email: "autorise@test.fr")
    recenseur_en_attente = create(:recenseur, email: "en-attente@test.fr")
    create(:recenseur_access, recenseur: recenseur_autorise, commune:, granted: true)
    create(:recenseur_access, recenseur: recenseur_en_attente, commune:, granted: nil)

    click_link "Recenseurs"

    expect(page).to have_text("autorise@test.fr")
    expect(page).to have_text("en-attente@test.fr")
  end
end
