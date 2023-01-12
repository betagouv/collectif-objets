# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Communes - send message", type: :feature, js: true do
  let!(:departement) { create(:departement, code: "26", nom: "Drôme") }
  let!(:commune) { create(:commune, nom: "Albon", code_insee: "26002", departement:) }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", role: "mairie", commune:, magic_token: "magiemagie") }

  it "should let user send a message" do
    login_as(user, scope: :user)
    visit "/"
    within("header") { click_on "Messagerie" }
    expect(page).to have_text(/Aucun message/i)
    fill_in "message[text]", with: "Bonjour,\nje suis sacrément perdu"
    expect(find('textarea[name="message[text]"]').value).to match(/bonjour/i)
    click_on "Envoyer"
    expect(page).to have_text(/Vous/i)
    expect(page).to have_text(/je suis sacrément perdu/i)
    expect(find('textarea[name="message[text]"]').value).to be_blank
  end
end
