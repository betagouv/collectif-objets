# frozen_string_literal: true

require "rails_helper"

RSpec.describe MemoireExportPhoto, type: :model do
  let!(:departement) { create(:departement, code: "52") }
  let!(:commune) { create(:commune, nom: "Anglefort", departement:) }
  let!(:edifice) { create(:edifice, nom: "Notre Dame", code_insee: commune.code_insee) }
  let!(:objet) do
    create(:objet, palissy_REF: "PM12345678", palissy_TICO: "La Sainte-Famille", palissy_CATE: "Peinture",
                   palissy_SCLE: "16e siècle", palissy_INSEE: "01010", commune:, edifice:)
  end
  let!(:recensement) { create(:recensement, :with_photo, objet:) }

  it "should be valid" do
    attachment = recensement.photos.first
    attachment.memoire_number = 1
    memoire_export_photo = MemoireExportPhoto.new(attachment:, recensement:)
    current_year = Time.zone.today.year
    expect(memoire_export_photo.memoire_LBASE).to eq("PM12345678")
    expect(memoire_export_photo.memoire_NUMP).to eq("#{current_year}052000001")
    expect(memoire_export_photo.memoire_REF).to eq("MHCO052_#{memoire_export_photo.memoire_NUMP}")
    expect(memoire_export_photo.memoire_REFIMG).to eq("#{memoire_export_photo.memoire_REF}.jpg")
    expect(memoire_export_photo.memoire_DATPV).to eq(current_year)
    expect(memoire_export_photo.memoire_COULEUR).to eq("Oui")
    expect(memoire_export_photo.memoire_OBS).to eq("Photographie fournie lors du recensement " \
                                                   "réalisé par Collectif Objets")
    expect(memoire_export_photo.memoire_COM).to eq("Anglefort")
    expect(memoire_export_photo.memoire_EDIF).to eq("Notre Dame")
    expect(memoire_export_photo.memoire_COPY).to eq("© Ministère de la Culture (France), Collectif Objets " \
                                                    "– Tous droits réservés")
    expect(memoire_export_photo.memoire_TYPDOC).to eq("Image numérique native")
    expect(memoire_export_photo.memoire_IDPROD).to eq("MHCO008")
    expect(memoire_export_photo.memoire_LIEUCOR).to eq("Collectif Objets")
    expect(memoire_export_photo.memoire_LEG).to eq("La Sainte-Famille")
    expect(memoire_export_photo.memoire_TECHOR).to eq("Peinture")
    expect(memoire_export_photo.memoire_SCLE).to eq("16e siècle")
    expect(memoire_export_photo.memoire_INSEE).to eq("01010")
  end
end
