# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Conservateurs - Gestion des recenseurs", type: :feature, js: true do
  let(:drome) { create(:departement, code: "26", nom: "Drôme") }
  let(:rhone) { create(:departement, code: "69", nom: "Rhône") }
  let(:albon) { create(:commune, nom: "Albon", code_insee: "26002", departement: drome) }
  let(:montelimar) { create(:commune, nom: "Montélimar", code_insee: "26198", departement: drome) }
  let(:conservateur) { create(:conservateur, departements: [drome]) }

  include ActiveJob::TestHelper

  before(:each) do
    login_as(conservateur, scope: :conservateur)
    visit "/"
  end

  scenario "Un conservateur peut gérer le statut d'un recenseur" do
    recenseur = create(:recenseur, email: "nouveau-recenseur@test.fr", nom: "nouveau-recenseur", status: :pending)
    create(:recenseur_access, recenseur:, commune: albon, granted: true)

    click_on "Recenseurs"
    expect(page).to have_text("Recenseurs")

    expect(page).to have_text(recenseur.email)

    click_on "Modifier"
    expect(page).to have_text("Modifier #{recenseur.nom}")
    select "Autorisé à recenser", from: "Statut"
    expect { click_on "Enregistrer" }.to have_enqueued_mail(RecenseurMailer)

    expect(page).to have_text("Recenseur modifié")
    expect(page).to have_text("Autorisé à recenser")
  end

  scenario "Un conservateur peut ajouter un accès à une commune pour un recenseur" do
    recenseur = create(:recenseur, email: "recenseur-existant@test.fr", status: :accepted)
    create(:recenseur_access, recenseur:, commune: albon, granted: true)

    click_on "Recenseurs"
    expect(page).to have_text("recenseur-existant@test.fr")

    visit conservateurs_recenseur_path(recenseur)
    within("#new_access") do
      fill_in "Rechercher une commune", with: montelimar.nom
      click_on "Rechercher"
    end
    expect(page).to have_text("Montélimar (26 - Drôme)")
    within(dom_id(montelimar)) do
      click_on "Ajouter l'accès"
    end

    # First check if the access was created
    access = RecenseurAccess.find_by(recenseur:, commune: montelimar)
    expect(access).to be_present
    expect(access.granted).to be_truthy

    # Then check if the button was updated
    expect(page).to have_button("Accès ajouté", disabled: true)
  end

  scenario "Un conservateur peut créer un nouveau recenseur" do
    click_on "Recenseurs"
    click_on "Créer un nouveau recenseur"

    fill_in "Email", with: "new-recenseur@test.fr"
    fill_in "Nom", with: "Nouveau Recenseur"
    select "Autorisé à recenser", from: "Statut"
    click_on "Enregistrer"

    expect(page).to have_text("Recenseur créé avec succès")
    expect(page).to have_text("new-recenseur@test.fr")

    recenseur = Recenseur.find_by(email: "new-recenseur@test.fr")
    expect(recenseur).to be_present
    expect(recenseur.accepted?).to be true
  end

  scenario "Un conservateur ne peut voir que les recenseurs de son département" do
    commune_hors_departement = create(:commune, nom: "Lyon", code_insee: "69123", departement: rhone)
    recenseur_visible = create(:recenseur, email: "dans-departement@test.fr", status: :accepted)
    create(:recenseur_access, recenseur: recenseur_visible, commune: albon, granted: true)

    recenseur_hors_departement = create(:recenseur, email: "hors-departement@test.fr", status: :accepted)
    create(:recenseur_access, recenseur: recenseur_hors_departement, commune: commune_hors_departement, granted: true)

    click_on "Recenseurs"
    expect(page).to have_text(recenseur_visible.email)
    expect(page).not_to have_text(recenseur_hors_departement.email)

    visit conservateurs_recenseur_path(recenseur_visible)
    within("#new_access") do
      fill_in "Rechercher une commune", with: "on"
      click_on "Rechercher"
    end

    # Seules les communes du département sont affichées
    expect(page).to have_text("Albon (26 - Drôme)")
    expect(page).not_to have_text("Lyon (69 - Rhône)")
  end
end
