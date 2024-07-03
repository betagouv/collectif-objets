# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Communes sign-in", type: :feature, js: true do
  let!(:departement) { create(:departement, code: "26", nom: "Drôme") }
  let!(:commune) { create(:commune, nom: "Albon", code_insee: "26002", departement:) }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", commune:) }

  include ActiveJob::TestHelper

  scenario "sign in with session code" do
    visit "/"
    click_on "Connexion commune"
    expect(page).to have_text("Connexion")
    select "26 - Drôme", from: "departement"
    click_on "Choisir le département"
    select "Albon", from: "code_insee"
    click_on "Choisir la commune"

    expect(page).to have_text("mairie-albon@test.fr")
    click_on "Recevoir un code de connexion"

    expect(page).to have_text("Code de connexion")
    perform_enqueued_jobs
    email = ActionMailer::Base.deliveries.last
    session_code = email.text_part.decoded.match(/[0-9]{6}/)
    expect(session_code).to be_present

    fill_in "code", with: session_code
    click_on "Connexion"

    expect(page).to have_text("Vous êtes maintenant connecté")
  end

  context "user has deprecated magic token" do
    let!(:user) { create(:user, email: "mairie-albon@test.fr", commune:, magic_token_deprecated: "blah123") }
    it "should redirect to connection page with commune preselected" do
      visit "/magic-authentication?magic-token=blah123"
      expect(page).to have_text("Connexion")
      expect(page).to have_text("ce lien de connexion n’est plus valide")
      expect(page).to have_text("Albon")
      expect(page).to have_text("mairie-albon@test.fr")
    end
  end
end
