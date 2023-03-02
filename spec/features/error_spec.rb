# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Error page", type: :feature, js: true do
  around :each do |example|
    Rails.application.config.consider_all_requests_local = false
    example.run
    Rails.application.config.consider_all_requests_local = true
  end

  scenario "visit health page" do
    visit "/"
    visit "/health/raise_on_purpose"
    expect(page).to have_text(/Erreur inattendue/i)
    expect(page).to have_text(/Erreur 500/i)
  end
end
