# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Sign in with token", type: :feature, js: true do
  let!(:departement) { create(:departement, code: "26", nom: "Drôme") }
  let!(:commune) { create(:commune, nom: "Albon", code_insee: "26002", departement:) }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", commune:, magic_token: "magiemagie") }

  include ActiveJob::TestHelper

  scenario "sign in with token" do
    visit "/"
    click_on "Connexion commune"
    expect(page).to have_text("Connexion")
    fill_in "Email", with: "mairie-albon@test.fr"
    click_on "Recevoir un lien de connexion"
    expect(page).to have_text("Veuillez cliquer sur le lien que vous avez reçu par mail pour vous connecter")

    perform_enqueued_jobs
    email = ActionMailer::Base.deliveries.last
    res = email.html_part.decoded.match(%r{/users/sign_in_with_token\?login_token=([a-z0-9]+)})
    expect(res).not_to be_nil
    sign_in_path = res[0]

    visit(sign_in_path)
    expect(page).to have_text("Vous êtes maintenant connecté")
  end
end
