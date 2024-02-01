# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Synchronizer::Objets::Batch::Base do
  let(:batch) { described_class.new(csv_rows) }
  context "deux lignes avec des refs merimee differentes" do
    let(:csv_rows) do
      [
        {
          "reference" => "PM01000001",
          "denomination" => "tableau",
          "categorie_technique" => "peinture",
          "commune_forme_index" => "Ambérieu-en-Bugey",
          "cog_insee" => "01004",
          "departement_format_numerique" => "01",
          "siecle_de_creation" => "1er quart 17e siècle",
          "date_du_recolement" => "2001",
          "typologie_du_dossier" => "dossier individuel",
          "nom_de_l_edifice" => "chapelle des Allymes",
          "emplacement_de_l_oeuvre_dans_l_edifice" => "chapelle située au milieu du cimetière",
          "titre_editorial" => "Tableau : Vierge du Rosaire",
          "reference_a_une_notice_merimee_mh" => "https://www.pop.culture.gouv.fr/notice/merimee/PA00113792",
          "date_et_typologie_de_la_protection" => "2007/01/29 : classé au titre objet",
          "typologie_de_la_protection" => "classé au titre objet"
        },
        {
          "reference" => "PM01000002",
          "denomination" => "photo",
          "categorie_technique" => "photographie",
          "commune_forme_index" => "Bois-Clair",
          "cog_insee" => "01053",
          "departement_format_numerique" => "01",
          "siecle_de_creation" => "1er quart 20e siècle",
          "date_du_recolement" => "20022",
          "typologie_du_dossier" => "dossier individuel",
          "nom_de_l_edifice" => "église Saint-André",
          "emplacement_de_l_oeuvre_dans_l_edifice" => "dans le choeur",
          "titre_editorial" => "Photo : église Saint-André",
          "reference_a_une_notice_merimee_mh" => "https://www.pop.culture.gouv.fr/notice/merimee/PA00113793",
          "date_et_typologie_de_la_protection" => "2007/01/29 : classé au titre objet",
          "typologie_de_la_protection" => "classé au titre objet"
        }
      ]
    end
    let!(:commune1) { create(:commune, nom: "Ambérieu-en-Bugey", code_insee: "01004") }
    let!(:commune2) { create(:commune, nom: "Bois-Clair", code_insee: "01053") }

    it "créé deux objets et deux édifices" do
      expect(batch.revisions.count).to eq 2
      batch.synchronize_each_revision
      expect(Objet.count).to eq 2
      expect(Edifice.count).to eq 2
    end
  end

  context "deux lignes avec la même ref Mérimée" do
    let(:csv_rows) do
      [
        {
          "reference" => "PM01000001",
          "denomination" => "tableau",
          "categorie_technique" => "peinture",
          "commune_forme_index" => "Ambérieu-en-Bugey",
          "cog_insee" => "01004",
          "departement_format_numerique" => "01",
          "siecle_de_creation" => "1er quart 17e siècle",
          "date_du_recolement" => "2001",
          "typologie_du_dossier" => "dossier individuel",
          "nom_de_l_edifice" => "chapelle des Allymes",
          "emplacement_de_l_oeuvre_dans_l_edifice" => "chapelle située au milieu du cimetière",
          "titre_editorial" => "Tableau : Vierge du Rosaire",
          "reference_a_une_notice_merimee_mh" => "https://www.pop.culture.gouv.fr/notice/merimee/PA00113792",
          "date_et_typologie_de_la_protection" => "2007/01/29 : classé au titre objet",
          "typologie_de_la_protection" => "classé au titre objet"
        },
        {
          "reference" => "PM01000002",
          "denomination" => "photo",
          "categorie_technique" => "photographie",
          "commune_forme_index" => "Ambérieu-en-Bugey",
          "cog_insee" => "01004",
          "departement_format_numerique" => "01",
          "siecle_de_creation" => "1er quart 20e siècle",
          "date_du_recolement" => "20022",
          "typologie_du_dossier" => "dossier individuel",
          "nom_de_l_edifice" => "église Saint-André",
          "emplacement_de_l_oeuvre_dans_l_edifice" => "dans le choeur",
          "titre_editorial" => "Photo : église Saint-André",
          "reference_a_une_notice_merimee_mh" => "https://www.pop.culture.gouv.fr/notice/merimee/PA00113792",
          "date_et_typologie_de_la_protection" => "2007/01/29 : classé au titre objet",
          "typologie_de_la_protection" => "classé au titre objet"
        }
      ]
    end
    let!(:commune) { create(:commune, nom: "Ambérieu-en-Bugey", code_insee: "01004") }

    it "créé deux objets mais un seul édifice" do
      expect(batch.revisions.count).to eq 2
      batch.synchronize_each_revision
      expect(Objet.count).to eq 2
      objets = Objet.all
      expect(Edifice.count).to eq 1
      edifice = Edifice.first
      expect(objets[0].edifice).to eq edifice
      expect(objets[1].edifice).to eq edifice
    end
  end
end
