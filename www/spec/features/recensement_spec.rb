# frozen_string_literal: true

# rubocop: disable Metrics/BlockLength

require "rails_helper"

RSpec.feature "Recensement", type: :feature, js: true do
  let!(:commune) { create(:commune, nom: "Albon", code_insee: "26002", departement: "26") }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", role: "mairie", commune:, magic_token: "magiemagie") }
  let!(:objet_bouquet) { create(:objet, nom: "Bouquet d'Autel", edifice_nom: "Eglise st Jean", commune:) }
  let!(:objet_ciboire) { create(:objet, nom: "Ciboire des malades", edifice_nom: "Musée", commune:) }

  scenario "full recensement" do
    login_as(user, scope: :user)
    visit "/"
    expect(page).to have_text("Albon")

    within("header") { click_on "Voir les objets de Albon" }
    expect(page).to have_text("Bouquet d'Autel")
    expect(page).to have_text("Ciboire des malades")

    click_on "Je confirme la participation de ma commune"
    fill_in "Nom", with: "Inès Rose"
    fill_in "Votre fonction", with: "Maire"
    fill_in "Numéro de téléphone", with: "01 01 01 01 01"
    fill_in "Commentaires", with: "J'ai super hâte"

    click_on "J'inscris Albon"
    expect(page).to have_text("Votre commune a bien été inscrite !")
    expect(page).to have_text("Il vous reste 2 objets à recenser")
    expect(page).to have_button("Finaliser le recensement", disabled: true)

    # PREMIER OBJET

    click_on "Bouquet d'Autel"
    expect(page).to have_text("PAS ENCORE RECENSÉ")
    expect(page).to have_text("st Jean")

    click_on "Recenser cet objet"
    expect(page).to have_selector("h2", text: "Recensement")
    find("label", text: "Je confirme m'être déplacé voir l'objet pour ce recensement").click
    find("label", text: "L'objet est bien présent dans l'édifice Eglise st Jean").click
    within("[data-recensement-target=recensable]") do
      find("label", text: "Oui").click
    end
    within("[data-recensement-target=etatSanitaireEdifice]") do
      find("label", text: "Moyen").click
    end
    within("[data-recensement-target=etatSanitaire]") do
      find("label", text: "Bon").click
    end
    within("[data-recensement-target=securisation]") do
      find("label", text: "Oui, il est difficile de le voler").click
    end
    find("label", text: "Je ne peux pas prendre cet objet en photo").click
    fill_in "Commentaires", with: "C'est un superbe pépito bleu"

    click_on "Enregistrer ce recensement"
    expect(page).to have_content("Votre recensement a bien été enregistré")

    # DEUXIEME OBJET
    expect(page).not_to have_button("Finaliser le recensement")
    expect(page).not_to have_content("Bouquet d'Autel")
    click_on "Ciboire des malades"
    expect(page).to have_text("PAS ENCORE RECENSÉ")
    expect(page).to have_text("Musée")

    click_on "Recenser cet objet"
    expect(page).to have_selector("h2", text: "Recensement")
    find("label", text: "Je confirme m'être déplacé voir l'objet pour ce recensement").click
    find("label", text: "L'objet est présent dans un autre édifice").click
    fill_in "Précisez le nom de l’édifice dans lequel se trouve l’objet *", with: "Salle des fêtes"
    within("[data-recensement-target=recensable]") do
      find("label", text: "Oui").click
    end
    within("[data-recensement-target=etatSanitaireEdifice]") do
      find("label", text: "Bon").click
    end
    within("[data-recensement-target=etatSanitaire]") do
      find("label", text: "Mauvais").click
    end
    within("[data-recensement-target=securisation]") do
      find("label", text: "Oui, il est difficile de le voler").click
    end
    find("label", text: "Je ne peux pas prendre cet objet en photo").click

    click_on "Enregistrer ce recensement"
    expect(page).to have_content("Votre recensement a bien été enregistré")

    # EDIT du deuxieme
    expect(page).to have_link("Finaliser le recensement")
    expect(page).not_to have_content("Bouquet d'Autel")
    expect(page).not_to have_content("Ciboire des malades")
    click_on "Revenir à la liste d'objets de ma commune"
    click_on "Ciboire des malades"
    click_on "modifier le recensement"
    within("[data-recensement-target=etatSanitaire]") do
      find("label", text: "En péril").click
    end
    click_on "Enregistrer ce recensement"
    expect(page).to have_content("Votre recensement a bien été enregistré")

    # CONFIRMATION
    click_on "Finaliser le recensement"
    expect(page).to have_content("Finalisation du recensement de Albon")
    fill_in("Commentaires", with: "Beau voyage")
    click_on "Je valide le recensement des objets de ma commune"
    expect(page).to have_content("Le recensement de votre commune est terminé !")
    click_on "Ciboire des malades"
    expect(page).not_to have_link("Recenser cet objet")
  end
end

# rubocop: enable Metrics/BlockLength
