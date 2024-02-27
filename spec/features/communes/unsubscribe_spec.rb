# frozen_string_literal: true

require "rails_helper"

feature "Communes unsubscribe from campaign", type: :feature, js: true do
  let!(:departement) { create(:departement, code: "26", nom: "Drôme") }
  let!(:commune) { create(:commune_with_user, nom: "Albon", code_insee: "26002", departement:) }
  let!(:campaign) { create(:campaign, departement:) }
  let!(:campaign_recipient) { create(:campaign_recipient, campaign:, commune:, unsubscribe_token: "blah123") }

  include ActiveJob::TestHelper

  scenario "unsubscribe from campaign emails with token" do
    visit new_user_unsubscribe_path(token: "blah123")
    expect(page).to be_axe_clean

    expect(page).to have_content("Désinscription")
    expect(page).to have_content("Albon")
    click_on "Désinscription"

    expect(page).to have_content("Albon a été désinscrite de la campagne de recensement")
  end
end
