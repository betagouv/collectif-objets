# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Communes", type: :feature, js: true do
  let!(:departement) { create(:departement, code: "26", nom: "Drôme") }
  let!(:commune) { create(:commune, nom: "Albon", code_insee: "26002", departement:) }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", commune:) }

  scenario "Recenseurs" do
    login_as(user, scope: :user)
    visit "/"

    click_link "Recenseurs"
    expect(page).to be_axe_clean

    # Ajoute un recenseur
    fill_in "Email", with: "test@test.fr"
    click_button "Demander l'accès"
    find("a[href='mailto:test@test.fr']")
    expect(page).to be_axe_clean

    # Un recenseur nouvellement créé doit être autorisé par le conservateur
    expect(page).to have_text("En attente")
    # La commune peut révoquer l'accès
    expect(page).to have_text("Révoquer l'accès")

    # Les communes peuvent supprimer l'accès
    accept_confirm do
      click_button "Révoquer l'accès"
    end
    find("p.empty")
    expect(page).to have_text("aucun recenseur")
    expect(page).to be_axe_clean
  end
end
