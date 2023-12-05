# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Communes - Recensement", type: :feature, js: true do
  # NOTE: for some reason these E2E specs are extremely flaky. It all comes from turbo drive and capybara failing
  # to correctly wait. I abandoned finding the proper solution and instead added sleep statements to make it work :(

  let!(:departement) { create(:departement, code: "26", nom: "Drôme") }
  let!(:commune) { create(:commune, nom: "Albon", code_insee: "26002", departement:) }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", role: "mairie", commune:, magic_token: "magiemagie") }
  let!(:edifice) { create(:edifice, code_insee: commune.code_insee) }
  let!(:objet_bouquet) do
    create(:objet, palissy_TICO: "Bouquet d’Autel", palissy_EDIF: "Eglise st Jean", commune:, edifice:)
  end
  let!(:objet_ciboire) do
    create(:objet, palissy_TICO: "Ciboire des malades", palissy_EDIF: "Musée", commune:, edifice:)
  end

  def navigate_to_objets
    login_as(user, scope: :user)
    visit "/"
    expect(page).to have_text("Albon")
    within("header") { click_on "Voir les objets de Albon" }
  end

  scenario "recensement of 2 objects + completion" do
    navigate_to_objets
    expect(page).to have_text("Bouquet d’Autel")
    expect(page).to have_text("Ciboire des malades")

    # PREMIER OBJET
    click_on "Bouquet d’Autel"
    expect(page).to have_text("PAS ENCORE RECENSÉ")
    expect(page).to have_text("st Jean")
    click_on "Recenser cet objet"

    # STEP 1
    expect(page).to have_text("Étape 1 sur 6")
    expect(page).to have_text("Recherche")
    expect(page).to have_text("Étape suivante : Localisation")
    expect(page).to have_text("Avez-vous trouvé l’objet ?")
    scroll_to(find("#recensement_form_step"))
    find("label", text: "Je confirme que je me suis bien déplacé").click
    click_on "Passer à l’étape suivante"

    # STEP 2
    expect(page).to have_text("Étape 2 sur 6")
    expect(page).to have_text("Localisation")
    expect(page).to have_text("Étape suivante : Photos de l’objet")
    expect(page).to have_text("Où se trouve l’objet ?")
    find("label", text: "L’objet se trouve dans l’édifice indiqué initialement").click
    expect(page).to have_text("L’objet est-il recensable ?")
    find("label", text: "L’objet est recensable").click
    click_on "Passer à l’étape suivante"

    # STEP 3
    expect(page).to have_text("Étape 3 sur 6")
    expect(page).to have_text("Photos de l’objet")
    expect(page).to have_text("Étape suivante : Objet")
    expect(page).to have_text("Prenez des photos de l’objet dans son état actuel")
    attach_file("recensement_photos", Rails.root.join("spec/fixture_files/tableau1.jpg"))
    expect(page).to have_selector("img[src*='tableau1.jpg']")
    attach_file("recensement_photos", Rails.root.join("spec/fixture_files/tableau2.jpg"))
    tableau2 = find("img[src*='tableau2.jpg']")
    expect(tableau2).to be_present
    tableau2.ancestor(".co-photo-preview").click_on "Supprimer"
    expect(page).not_to have_selector("img[src*='tableau2.jpg']")
    click_on "Passer à l’étape suivante"

    # Step 4
    expect(page).to have_text("Étape 4 sur 6")
    expect(page).to have_text("Objet")
    expect(page).to have_text("Étape suivante : Commentaires")
    expect(page).to have_text("Quel est l’état actuel de l’objet ?")
    find("label", text: "L’objet est en état moyen").click
    expect(page).to have_text("L’objet est-il en sécurité ?")
    find("label", text: "L’objet est difficile à voler").click
    click_on "Passer à l’étape suivante"

    # Step 5
    expect(page).to have_text("Étape 5 sur 6")
    expect(page).to have_text("Commentaires")
    expect(page).to have_text("Étape suivante : Récapitulatif")
    expect(page).to have_text("Avez-vous des commentaires ?")
    fill_in "Avez-vous des commentaires ?", with: "Cette peinture est magnifique"
    click_on "Passer à l’étape suivante"

    # Step 6 - Recap
    expect(page).to have_text("Étape 6 sur 6")
    expect(page).to have_text("Récapitulatif")
    expect(page).not_to have_text("Étape suivante")
    expect(page).to have_text("Je confirme que je me suis bien déplacé et que j’ai trouvé l’objet")
    expect(page).to have_text("L’objet se trouve dans l’édifice indiqué initialement: Eglise st Jean")
    expect(page).to have_text("L’objet est recensable")
    expect(page).to have_selector("img[src*='tableau1.jpg']")
    expect(page).to have_text("L’objet est en état moyen")
    expect(page).to have_text("L’objet est difficile à voler")
    expect(page).to have_text("Cette peinture est magnifique")
    click_on "Valider le recensement de cet objet"

    # Confirmation page
    expect(page).to have_text("Votre recensement a bien été enregistré")
    expect(page).to have_text("Ciboire des malades")
    find("a", text: "Revenir à la liste d’objets de ma commune", match: :first).click

    # Objets index
    expect(page).to have_text("Il reste un objet protégé à recenser")
    card_bouquet = find("a", text: "Bouquet d’Autel").ancestor(".fr-card")
    expect(card_bouquet).to have_text(/Recensé/i)
    card_ciboire = find("a", text: "Ciboire des malades").ancestor(".fr-card")
    expect(card_ciboire).to have_text(/Pas encore recensé/i)
    click_on "Ciboire des malades"

    # SECOND OBJET
    expect(page).to have_text(/Pas encore recensé/i)
    click_on "Recenser cet objet"
    expect(page).to have_text("Étape 1 sur 6")
    # "comment ça marche" accordion should be closed for successive recensements
    expect(page).not_to have_text("Je me rends sur place pour recenser mes objets protégés et les prendre en photo")
    find("label", text: "Je confirme que je me suis bien déplacé").click
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 2 sur 6")
    find("label", text: "L’objet se trouve dans l’édifice indiqué initialement").click
    find("label", text: "L’objet est recensable").click
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 3 sur 6")
    attach_file("recensement_photos", Rails.root.join("spec/fixture_files/peinture1.jpg"))
    expect(page).to have_selector("img[src*='peinture1.jpg']")
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 4 sur 6")
    find("label", text: "L’objet est en bon état").click
    find("label", text: "L’objet est difficile à voler").click
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 5 sur 6")
    expect(page).to have_text("Avez-vous des commentaires ?")
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 6 sur 6")
    click_on "Valider le recensement de cet objet"

    # Confirmation
    expect(page).to have_text("Vous avez recensé tous les objets de votre commune")
    click_on "Finaliser le recensement…"

    # Completion page
    row_bouquet = find("a", text: "Bouquet d’Autel").ancestor("tr")
    expect(row_bouquet).to have_text(/Recensable/i)
    expect(row_bouquet).to have_text(/L’objet est en état moyen/i)
    expect(row_bouquet).to have_text(/Difficile à voler/i)
    expect(row_bouquet).to have_selector("img[src*='tableau1.jpg']")
    row_ciboire = find("a", text: "Ciboire des malades").ancestor("tr")
    expect(row_ciboire).to have_text(/Recensable/i)
    expect(row_ciboire).to have_text(/L’objet est en bon état/i)
    expect(row_ciboire).to have_text(/Difficile à voler/i)
    expect(row_ciboire).to have_selector("img[src*='peinture1.jpg']")
    fill_in("Vos commentaires", with: "C’était fort sympathique")
    click_on "Je valide le recensement des objets de ma commune"

    expect(page).to have_text("Le recensement de vos objets est terminé, merci !")
  end

  scenario "recensement introuvable" do
    navigate_to_objets
    click_on "Bouquet d’Autel"
    click_on "Recenser cet objet"

    expect(page).to have_text("Étape 1 sur 6")
    find("label", text: "Je ne trouve pas l’objet").click
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Je confirme ne pas trouver l’objet")
    click_on "Annuler"
    expect(page).to have_text("Avez-vous trouvé l’objet ?")
    find("label", text: "Je ne trouve pas l’objet").click
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Je confirme ne pas trouver l’objet")
    click_on "Confirmer et continuer"
    expect(page).to have_text("Étape 5 sur 6")
    expect(page).to have_text("Avez-vous des commentaires ?")
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 6 sur 6")
    click_on "Valider le recensement de cet objet"

    find_all("a", text: "Revenir à la liste d’objets de ma commune").first.click
    card_bouquet = find(".fr-card", text: "Bouquet d’Autel")
    expect(card_bouquet).to have_text(/Recensé/i)
    card_bouquet.click
    click_on "Modifier le recensement"
    expect(page).to have_text("Étape 6 sur 6")
    expect(page).to have_text("Récapitulatif")
    find("section", text: "Avez-vous trouvé l’objet ?").find('button[aria-label="Modifier la réponse"]').click
    expect(page).to have_text("Étape 1 sur 6")
    find("label", text: "Je confirme que je me suis bien déplacé et que j’ai trouvé l’objet").click
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 2 sur 6")
    expect(page).to have_text("Où se trouve l’objet ?")

    #  le recensement repasse en draft quand on change cette réponse
    sleep 0.5
    click_on "Objets de Albon"
    card_bouquet = find(".fr-card:not(.fr-card--horizontal)", text: "Bouquet d’Autel")
    expect(card_bouquet).not_to be_nil
    expect(card_bouquet).not_to have_text(/Recensé/i)
    expect(card_bouquet).to have_text(/Recensement à compléter/i)
    card_bouquet.click
    click_on "Compléter le recensement"
    expect(page).to have_text("Étape 1 sur 6")
    expect(page).to have_text("Recherche")
    expect(
      find(".fr-radio-group", text: "Je confirme que je me suis bien déplacé et que j’ai trouvé l’objet")
        .find("input", visible: false)
    ).to be_checked
  end

  scenario "recensement non recensable" do
    navigate_to_objets
    click_on "Bouquet d’Autel"
    click_on "Recenser cet objet"

    expect(page).to have_text("Étape 1 sur 6")
    find("label", text: "Je confirme que je me suis bien déplacé").click
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 2 sur 6")
    find("label", text: "L’objet se trouve dans l’édifice indiqué initialement").click
    find("label", text: "L’objet n’est pas recensable").click
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Je confirme que l’objet n’est pas recensable")
    click_on "Annuler"
    find("label", text: "L’objet n’est pas recensable").click
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Je confirme que l’objet n’est pas recensable")
    click_on "Confirmer et continuer"
    expect(page).to have_text("Étape 5 sur 6")
    expect(page).to have_text("Avez-vous des commentaires ?")
    click_on "Revenir à l’étape précédente"
    expect(page).to have_text("Étape 2 sur 6")
    expect(page).to have_text("Localisation")
    expect(find(".fr-radio-group", text: "L’objet n’est pas recensable").find("input", visible: false)).to be_checked
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 5 sur 6")
    expect(page).to have_text("Avez-vous des commentaires ?")
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 6 sur 6")
    expect(page).to have_text("Récapitulatif")
    expect(page).to have_text("L’objet n’est pas recensable")
    expect(page).not_to have_text(/Photos/i)
    click_on "Valider le recensement de cet objet"

    find_all("a", text: "Revenir à la liste d’objets de ma commune").first.click
    card_bouquet = find(".fr-card", text: "Bouquet d’Autel")
    expect(card_bouquet).to have_text(/Recensé/i)
    card_bouquet.click
    click_on "Modifier le recensement"
    expect(page).to have_text("Étape 6 sur 6")
    expect(page).to have_text("Récapitulatif")
    find("section", text: "L’objet n’est pas recensable").find('button[aria-label="Modifier la réponse"]').click
    expect(page).to have_text("Étape 2 sur 6")
    find("label", text: "L’objet est recensable").click
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 3 sur 6")
    expect(page).to have_text("Photos de l’objet")
    click_on "Objets de Albon"
    card_bouquet = find(".fr-card:not(.fr-card--horizontal)", text: "Bouquet d’Autel")
    expect(card_bouquet).to have_text(/Recensement à compléter/i)
    card_bouquet.click
    click_on "Compléter le recensement"
    expect(page).to have_text("Étape 1 sur 6")
    expect(page).to have_text("Recherche")
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 2 sur 6")
    expect(page).to have_text("Localisation")
    expect(find(".fr-radio-group", text: "L’objet est recensable").find("input", visible: false)).to be_checked
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 3 sur 6")
  end

  scenario "recensement without photos" do
    navigate_to_objets
    click_on "Bouquet d’Autel"
    click_on "Recenser cet objet"

    expect(page).to have_text("Étape 1 sur 6")
    find("label", text: "Je confirme que je me suis bien déplacé").click
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 2 sur 6")
    find("label", text: "L’objet se trouve dans l’édifice indiqué initialement").click
    find("label", text: "L’objet est recensable").click
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 3 sur 6")
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Êtes-vous sûr de ne pas pouvoir prendre de photos ?")
    click_on "Annuler" # same here
    click_on "Passer à l’étape suivante"
    click_on "Confirmer et continuer"
    expect(page).to have_text("Étape 4 sur 6")
    find("label", text: "L’objet est en bon état").click
    find("label", text: "L’objet est difficile à voler").click
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 5 sur 6")
    expect(page).to have_text("Commentaires")
    click_on "Passer à l’étape suivante"
    expect(page).to have_text("Étape 6 sur 6")
    expect(page).to have_text("Récapitulatif")
    expect(page).to have_text(/Photos manquantes/i)
    click_on "Valider le recensement de cet objet"
    expect(page).to have_text("Votre recensement a bien été enregistré")
  end

  scenario "aucun choix à l’étape 1" do
    navigate_to_objets
    click_on "Bouquet d’Autel"
    click_on "Recenser cet objet"
    expect(page).to have_text("Étape 1 sur 6")
    click_on "Passer à l’étape suivante"
    scroll_to(find("#recensement_form_step"))
    expect(page).to have_text("Étape 1 sur 6")
    expect(page).to have_text("Recherche")
    expect(page).to have_text("Veuillez choisir une option")
  end
end
