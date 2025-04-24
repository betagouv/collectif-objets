# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Recenseurs - Recensement", type: :feature, js: true do
  let(:drome) { create(:departement, code: "26", nom: "Drôme") }
  let(:albon) { create(:commune, nom: "Albon", code_insee: "26002", departement: drome) }
  let(:montelimar) { create(:commune, nom: "Montélimar", code_insee: "26198", departement: drome) }
  let(:objet) do
    create(:objet, palissy_TICO: "Bouquet d’Autel", palissy_EDIF: "Eglise st Jean", commune: albon, edifice:)
  end
  let!(:edifice) { create(:edifice, code_insee: albon.code_insee) }
  let!(:recenseur) { create(:recenseur, email: "recenseur@test.fr", status: :accepted) }
  let!(:access) { create(:recenseur_access, recenseur:, commune: albon, granted: true, notified: true) }

  include ActiveJob::TestHelper

  before(:each) { login_as(recenseur, scope: :recenseur) }

  scenario "Un recenseur voit les communes qui lui sont associées" do
    create(:recenseur_access, recenseur:, commune: montelimar, granted: false)
    visit recenseurs_communes_path

    expect(page).to have_text("Communes")
    expect(page).to have_text("Albon")
    expect(page).not_to have_text("Montélimar")
    expect(page).to be_axe_clean
  end

  scenario "Un recenseur peut recenser un objet" do
    visit recenseurs_commune_path(albon)

    expect(page).to have_text("Bouquet d’Autel")

    click_on "Bouquet d’Autel"
    expect(page).to have_text("PAS ENCORE RECENSÉ")
    expect(page).to have_text("st Jean")
    expect(page).to be_axe_clean
    click_on "Recenser"

    card_bouquet = find(".fr-card:not(.fr-card--horizontal)", text: "Bouquet d’Autel")
    expect(card_bouquet).to have_text(/Recensement à compléter/i)
  end
end
