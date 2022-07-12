# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.feature "Sign in with password", type: :feature, js: true do
  let!(:conservateur) do
    create(:conservateur, email: "jeanne.michel@culture.gouv.fr", password: "super-long-mot-de-passe-du-futur")
  end

  scenario "sign in with correct password" do
    visit "/"
    click_on "Connexion"
    click_on "Je suis conservateur ou conservatrice"
    fill_in "Email", with: "jeanne.michel@culture.gouv.fr"
    fill_in "Mot de passe", with: "super-long-mot-de-passe-du-futur"
    find_button("Se connecter").click
    expect(page).to have_text("Connecté(e)")
  end

  scenario "sign in with wrong password" do
    visit "/"
    click_on "Connexion"
    click_on "Je suis conservateur ou conservatrice"
    fill_in "Email", with: "jeanne.michel@culture.gouv.fr"
    fill_in "Mot de passe", with: "abcdef"
    find_button("Se connecter").click
    expect(page).not_to have_text("Connecté(e)")
    expect(page).to have_text("Email ou mot de passe incorrect")
  end

  scenario "sign in with wrong email" do
    visit "/"
    click_on "Connexion"
    click_on "Je suis conservateur ou conservatrice"
    fill_in "Email", with: "michel.jean@culture.gouv.fr"
    fill_in "Mot de passe", with: "super-long-mot-de-passe-du-futur"
    find_button("Se connecter").click
    expect(page).not_to have_text("Connecté(e)")
    expect(page).to have_text("Email ou mot de passe incorrect")
  end
end
# rubocop:enable Metrics/BlockLength
