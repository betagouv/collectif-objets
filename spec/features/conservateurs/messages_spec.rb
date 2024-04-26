# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Conservateurs - messages", type: :feature, js: true do
  let!(:departement) { create(:departement, code: "26", nom: "Drôme") }
  let!(:commune) { create(:commune, nom: "Albon", code_insee: "26002", departement:) }
  let!(:user) { create(:conservateur, departements: [departement]) }

  it "should let user send a message" do
    login_as(user, scope: :conservateur)
    visit "/conservateurs/communes/#{commune.id}/messages"
    expect(page).to be_axe_clean
    expect(page).to have_text(/Attention à vos données à caractère personnel/i)
    expect(page).to have_text(/Aucun message/i)
    fill_in "message[text]", with: "Bonjour,\nje suis sacrément perdu"
    expect(find('textarea[name="message[text]"]').value).to match(/bonjour/i)
    click_on "Envoyer"
    expect(page).to have_text(/Vous/i)
    expect(page).to have_text(/je suis sacrément perdu/i)
    expect(page).to be_axe_clean
    expect(find('textarea[name="message[text]"]').value).to be_blank
  end
end
