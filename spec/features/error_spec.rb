# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Error page", type: :feature, js: true do
  scenario "visit 404 page" do
    visit "/404"
    expect(page).to be_axe_clean
  end
end
