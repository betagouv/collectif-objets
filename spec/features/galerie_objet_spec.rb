# frozen_string_literal: true

require "rails_helper"

feature "Galerie objet photos palissy", type: :feature, js: true do
  context "three photos" do
    let!(:objet) { create(:objet, :with_palissy_photos) }

    it "should be navigable" do
      visit objet_path(objet)
      expect(page).to have_text("3 photos connues")
      expect(page).to have_selector("img[src*='objet1.jpg']")
      expect(find("h1", text: /La Sainte-Famille/)).to be_visible
      click_on "Voir ou modifier les 3 photos"
      expect(page).to have_selector(".co-galerie")
      expect(page).to have_selector('button[disabled][title="photo précédente"]')
      click_on "photo suivante"
      click_on "photo suivante"
      expect(page).to have_selector('button[disabled][title="photo suivante"]')
      click_on "photo précédente"
      click_on "Fermer"
      expect(page).not_to have_selector(".co-galerie")
    end
  end
end
