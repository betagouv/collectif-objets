# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Conservateurs - commune", type: :feature, js: true do
  let!(:departement) { create(:departement, code: "26", nom: "Drôme") }
  let!(:commune) { create(:commune, nom: "Albon", code_insee: "26002", departement:) }
  let!(:user) { create(:conservateur, departements: [departement]) }

  before(:each) { login_as(user, scope: :conservateur) }

  it "liste les objets de la commune" do
    edifice = create(:edifice, commune:)
    objet = create(:objet, nom: "Fauteuil confortable", edifice:)
    visit "/conservateurs/communes/#{commune.id}"
    expect(page).to be_axe_clean
    expect(page).to have_text(/Non recensé/i)
    expect(page).to have_text(objet.nom)
  end

  it "affiche le dossier de la commune" do
    visit "/conservateurs/communes/#{commune.id}/dossier"
    expect(page).to be_axe_clean
    expect(page).to have_text(/L'examen est généré lors de l’acceptation du dossier/i)
  end

  it "affiche les anciens dossiers de la commune" do
    create(:dossier, :archived, commune:)
    visit "/conservateurs/communes/#{commune.id}/historique"
    expect(page).to be_axe_clean
    expect(page).to have_text(/Historique de la commune/i)
  end
end
