# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Conservateurs - Accept Dossier", type: :feature, js: true do
  let!(:departement) { create(:departement, code: "26", nom: "Drôme") }
  let!(:conservateur) { create(:conservateur, email: "jeanne@culture.gouv.fr", departements: [departement]) }
  let!(:commune) do
    create(:commune, nom: "Albon", code_insee: "26002", departement:, status: Commune::STATE_COMPLETED)
  end
  let!(:edifice) { create(:edifice, code_insee: "26002", nom: "Église St Jean", slug: "eglise-st-jean") }
  let!(:dossier) { create(:dossier, :submitted, commune:) }
  before { commune.update!(dossier:) }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", commune:) }
  let!(:objet_bouquet) { create(:objet, palissy_TICO: "Bouquet d'Autel", edifice:, commune:) }
  let!(:recensement_bouquet) do
    create(
      :recensement,
      :with_photos,
      photos_count: 3,
      objet: objet_bouquet,
      dossier:,
      etat_sanitaire: Recensement::ETAT_BON,
      securisation: Recensement::SECURISATION_CORRECTE,
      notes: "objet très doux"
    )
  end
  let!(:objet_ciboire) { create(:objet, palissy_TICO: "Ciboire des malades", commune:, edifice:) }
  let!(:recensement_ciboire) do
    create(
      :recensement,
      objet: objet_ciboire,
      dossier:,
      etat_sanitaire: Recensement::ETAT_PERIL,
      securisation: Recensement::SECURISATION_CORRECTE,
      notes: nil
    )
  end

  scenario "full" do
    login_as(conservateur, scope: :conservateur)
    visit "/"
    expect(page).to have_text("Drôme")
    click_on "26 - Drôme"

    expect(page).to have_text("Albon")
    click_on "Albon"

    expect(page).to have_text("Bouquet d'Autel")
    expect(page).to have_text("Ciboire des malades")

    # examen first recensement
    click_on "Bouquet d'Autel"
    # galerie - navigation
    #  find(".co-galerie .content .photo img")[:src].match(%r{blobs/proxy/(.*)/(.*.jpg)})[1] }
    def current_img
      find(".co-galerie .content .photo img")[:src]
        .match(%r{blobs/proxy/(?<blob_id>.*)/(?<filename>.*)$})
    end
    click_on "Voir ou modifier les 3 photos"
    expect(page).to have_css('button[title="photo précédente"][disabled]')
    expect(page).to have_text("Photo 1 / 3")
    expect(current_img[:filename]).to eq "tableau1.jpg"
    find('button[title="photo suivante"]').click
    expect(page).to have_text("Photo 2 / 3")
    expect(current_img[:filename]).to eq "tableau2.jpg"
    expect(page).to have_css('button[title="photo précédente"]:not([disabled])')
    find('button[title="photo suivante"]').click
    expect(page).to have_text("Photo 3 / 3")
    expect(current_img[:filename]).to eq "tableau3.jpg"
    expect(page).to have_css('button[title="photo suivante"][disabled]')
    find('button[title="photo précédente"]').click
    expect(page).to have_text("Photo 2 / 3")
    expect(current_img[:filename]).to eq "tableau2.jpg"
    # galerie - pivoter
    blob_id_before_rotate = find(".co-galerie .content .photo img")[:src].match(%r{blobs/proxy/(.*)/tableau2.jpg})[1]
    find("button", text: /Pivoter/).click
    sleep(1)
    blob_id_after_rotate = find(".co-galerie .content .photo img")[:src].match(%r{blobs/proxy/(.*)/tableau2.jpg})[1]
    expect(blob_id_before_rotate).not_to eq(blob_id_after_rotate)
    expect(current_img[:filename]).to eq "tableau2.jpg"
    # galerie - supprimer
    find("button", text: /Supprimer/).click
    expect(page).to have_text("Êtes-vous sûr de vouloir supprimer cette photo ?")
    find(".fr-modal__footer").click_on "Supprimer"
    expect(page).to have_text("Photo 2 / 2")
    expect(current_img[:filename]).to eq "tableau3.jpg" # 2 -> ø, 3 -> 2
    # galerie - ajout
    find("button", text: /Ajouter/).click
    # click_on "Ajouter une photo" # not necessary when using `make_visible: true`
    attach_file("new_blob_id", Rails.root.join("spec/fixture_files/tableau2.jpg"), make_visible: true)
    expect(page).to have_text("Photo 3 / 3")
    expect(current_img[:filename]).to eq "tableau2.jpg"
    find("button", text: /Fermer/).click

    etat_sanitaire_group = find("div", text: /État de l’objet/, class: "co-text--bold")
      .find(:xpath, "ancestor::div[contains(@class, 'attribute-group')]")
    within(etat_sanitaire_group) do
      click_on "Modifier"
      select "L’objet est en péril", from: "recensement[analyse_etat_sanitaire]"
    end
    find("label", text: /Informer la commune sur les mesures d’entretien des édifices/).click
    fill_in "recensement[analyse_notes]", with: "Est-ce qu'il est le pepito bleu?"

    click_on "Sauvegarder"
    expect(page).to have_text("Votre examen a bien été sauvegardé")

    # examen second recensement
    click_on "Ciboire des malades"
    securisation_group = find("div", text: /Sécurisation de l’objet/, class: "co-text--bold")
      .find(:xpath, "ancestor::div[contains(@class, 'attribute-group')]")
    within(securisation_group) do
      click_on "Modifier"
      select "L’objet est facile à voler", from: "recensement[analyse_securisation]"
    end

    click_on "Sauvegarder"
    expect(page).to have_text("L’ensemble des objets en péril ou disparus ont été examinés")

    # envoi rapport
    click_on "Envoyer l'examen à la commune"
    bouquet_row = find_link("Bouquet d'Autel").find(:xpath, "ancestor::tr")
    expect(bouquet_row).to have_text(/Entretien de l’édifice et lutte contre les infestations/i)
    expect(bouquet_row.all("td")[1]).to have_text(/Bon/i)
    expect(bouquet_row.all("td")[1]).to have_text(/L’objet est en péril/i)
    ciboire_row = find_link("Ciboire des malades").find(:xpath, "ancestor::tr")
    expect(ciboire_row).not_to have_text(/Entretien de l’édifice et lutte contre les infestations/i)
    fill_in("dossier[notes_conservateur]", with: "Merci pour ce joli dossier")
    click_on "Finaliser et envoyer l'examen à la commune"

    # visualisation rapport
    expect(page).to have_text(/Tous les recensements ont été examinés/i)
    click_on "Voir l'examen"
    expect(page).to have_text(/Ciboire des malades/i)
    expect(page).to have_text(/Merci pour ce joli dossier/i)
    expect(page).to have_text(/pepito bleu/i)
  end
end
