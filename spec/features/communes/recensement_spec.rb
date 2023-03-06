# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Communes - Recensement", type: :feature, js: true do
  let!(:departement) { create(:departement, code: "26", nom: "Drôme") }
  let!(:commune) { create(:commune, nom: "Albon", code_insee: "26002", departement:) }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", role: "mairie", commune:, magic_token: "magiemagie") }
  let!(:objet_bouquet) { create(:objet, palissy_TICO: "Bouquet d'Autel", palissy_EDIF: "Eglise st Jean", commune:) }
  let!(:objet_ciboire) { create(:objet, palissy_TICO: "Ciboire des malades", palissy_EDIF: "Musée", commune:) }

  scenario "full recensement" do
    login_as(user, scope: :user)
    visit "/"
    expect(page).to have_text("Albon")

    within("header") { click_on "Voir les objets de Albon" }
    expect(page).to have_text("Bouquet d'Autel")
    expect(page).to have_text("Ciboire des malades")

    # PREMIER OBJET

    click_on "Bouquet d'Autel"
    expect(page).to have_text("PAS ENCORE RECENSÉ")
    expect(page).to have_text("st Jean")

    click_on "Recenser cet objet"
    expect(page).to have_selector("h1", text: "Recensement")
    find("label", text: "Je confirme m'être déplacé voir l'objet pour ce recensement").click
    find("label", text: "L'objet est bien présent dans l'édifice Eglise st Jean").click
    within("[data-recensement-target=recensable]") do
      find("label", text: "Oui").click
    end
    within("[data-recensement-target=etatSanitaireEdifice]") do
      find("label", text: "L'édifice est en état moyen").click
    end
    within("[data-recensement-target=etatSanitaire]") do
      find("label", text: "L'objet est en bon état").click
    end
    within("[data-recensement-target=securisation]") do
      find("label", text: "L’objet est facile à voler").click
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
    expect(page).to have_selector("h1", text: "Recensement")
    find("label", text: "Je confirme m'être déplacé voir l'objet pour ce recensement").click
    find("label", text: "L'objet est présent dans un autre édifice").click
    fill_in "Précisez le nom de l’édifice dans lequel se trouve l’objet *", with: "Salle des fêtes"
    within("[data-recensement-target=recensable]") do
      find("label", text: "Oui").click
    end
    within("[data-recensement-target=etatSanitaireEdifice]") do
      find("label", text: "L'édifice est en bon état").click
    end
    within("[data-recensement-target=etatSanitaire]") do
      find("label", text: "L'objet est en mauvais état").click
    end
    within("[data-recensement-target=securisation]") do
      find("label", text: "L’objet est facile à voler").click
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
      find("label", text: "L'objet est en péril").click
    end
    click_on "Enregistrer ce recensement"
    expect(page).to have_content("Votre recensement a bien été enregistré")

    # CONFIRMATION
    save_screenshot("recensement.png")
    click_on "Finaliser le recensement"
    expect(page).to have_content("Finalisation du recensement de Albon")
    fill_in("Vos commentaires à destination des conservateurs", with: "Beau voyage")
    accept_confirm do
      click_on "Je valide le recensement des objets de ma commune"
    end
    expect(page).to have_content("Le recensement de votre commune est terminé !")
    click_on "Ciboire des malades"
    expect(page).not_to have_link("Recenser cet objet")
  end

  context "commune has validation error" do
    before { commune.update_columns(nom: " Albon ") }
    scenario "recensement cannot save but doesn't explode" do
      login_as(user, scope: :user)
      visit "/"
      within("header") { click_on "Voir les objets de Albon" }
      click_on "Bouquet d'Autel"
      click_on "Recenser cet objet"
      find("label", text: "Je confirme m'être déplacé voir l'objet pour ce recensement").click
      find("label", text: "L'objet est bien présent dans l'édifice Eglise st Jean").click
      within("[data-recensement-target=recensable]") do
        find("label", text: "Oui").click
      end
      within("[data-recensement-target=etatSanitaireEdifice]") do
        find("label", text: "L'édifice est en état moyen").click
      end
      within("[data-recensement-target=etatSanitaire]") do
        find("label", text: "L'objet est en bon état").click
      end
      within("[data-recensement-target=securisation]") do
        find("label", text: "L’objet est facile à voler").click
      end
      find("label", text: "Je ne peux pas prendre cet objet en photo").click
      fill_in "Commentaires", with: "C'est un superbe pépito bleu"

      click_on "Enregistrer ce recensement"
      expect(page).to have_content(/erreur 500/i)
    end
  end

  scenario "recensement with missing photos" do
    login_as(user, scope: :user)
    visit "/"
    within("header") { click_on "Voir les objets de Albon" }
    click_on "Bouquet d'Autel"
    click_on "Recenser cet objet"
    find("label", text: "Je confirme m'être déplacé voir l'objet pour ce recensement").click
    find("label", text: "L'objet est bien présent dans l'édifice Eglise st Jean").click
    within("[data-recensement-target=recensable]") do
      find("label", text: "Oui").click
    end
    within("[data-recensement-target=etatSanitaireEdifice]") do
      find("label", text: "L'édifice est en état moyen").click
    end
    within("[data-recensement-target=etatSanitaire]") do
      find("label", text: "L'objet est en bon état").click
    end
    within("[data-recensement-target=securisation]") do
      find("label", text: "L’objet est facile à voler").click
    end
    # find("label", text: "Je ne peux pas prendre cet objet en photo").click
    fill_in "Commentaires", with: "C'est un superbe pépito bleu"

    click_on "Enregistrer ce recensement"
    expect(page).to have_content(/Votre recensement n'a pas pu être enregistré/i)
    expect(page).to have_content(/Les photos sont fortement recommandées/i)
  end
end
