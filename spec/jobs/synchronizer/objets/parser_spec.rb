# frozen_string_literal: true

require "rails_helper"

RSpec.describe Synchronizer::Objets::Parser do
  let(:base_row) do
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
      "typologie_de_la_protection" => "classé au titre objet",
      "lieu_de_deplacement_de_l_objet" => "", # DEPL
      "code_insee_commune_actuelle" => "", # WEB
      "edifice_actuel" => "" # MOSA
    }
  end
  let(:obj) { Object.new.extend(described_class) }

  context "changements simples" do
    let(:attributes) { obj.parse_row_to_objet_attributes(base_row) }
    it "tous les champs sont bien parsés" do
      expect(attributes[:palissy_REF]).to eq "PM01000001"
      expect(attributes[:palissy_DENO]).to eq "tableau"
      expect(attributes[:palissy_CATE]).to eq "peinture"
      expect(attributes[:palissy_COM]).to eq "Ambérieu-en-Bugey"
      expect(attributes[:palissy_INSEE]).to eq "01004"
      expect(attributes[:palissy_DPT]).to eq "01"
      expect(attributes[:palissy_SCLE]).to eq "1er quart 17e siècle"
      expect(attributes[:palissy_DENQ]).to eq "2001"
      expect(attributes[:palissy_DOSS]).to eq "dossier individuel"
      expect(attributes[:palissy_EDIF]).to eq "chapelle des Allymes"
      expect(attributes[:palissy_EMPL]).to eq "chapelle située au milieu du cimetière"
      expect(attributes[:palissy_TICO]).to eq "Tableau : Vierge du Rosaire"
      expect(attributes[:palissy_REFA]).to eq "PA00113792"
      expect(attributes[:palissy_DPRO]).to eq "2007/01/29 : classé au titre objet"
      expect(attributes[:palissy_PROT]).to eq "classé au titre objet"
      expect(attributes[:palissy_DEPL]).to eq nil
      expect(attributes[:palissy_WEB]).to eq nil
      expect(attributes[:palissy_MOSA]).to eq nil
      expect(attributes[:lieu_actuel_code_insee]).to eq "01004"
      expect(attributes[:lieu_actuel_edifice_nom]).to eq "chapelle des Allymes"
      expect(attributes[:lieu_actuel_edifice_ref]).to eq "PA00113792"
      expect(attributes[:lieu_actuel_departement_code]).to eq "01"
    end
  end

  context "fusion de commune : code_insee_commune_actuelle est rempli mais pas de lieu_de_deplacement" do
    let(:row) do
      base_row.merge(
        "lieu_de_deplacement_de_l_objet" => "",
        "code_insee_commune_actuelle" => "01235"
      )
    end
    let(:attributes) { obj.parse_row_to_objet_attributes(row) }
    it "le code insee de la commune actuelle est bien parsé" do
      expect(attributes[:palissy_INSEE]).to eq "01004"
      expect(attributes[:palissy_WEB]).to eq "01235"
      expect(attributes[:palissy_DEPL]).to eq nil
      expect(attributes[:palissy_MOSA]).to eq nil
      expect(attributes[:lieu_actuel_code_insee]).to eq "01235"
      expect(attributes[:lieu_actuel_edifice_nom]).to eq "chapelle des Allymes"
      expect(attributes[:lieu_actuel_edifice_ref]).to eq "PA00113792"
      expect(attributes[:lieu_actuel_departement_code]).to eq "01"
    end
  end

  context "déplacement d’objet, pas de ref merimée actuelle renseignée" do
    let(:row) do
      base_row.merge(
        "lieu_de_deplacement_de_l_objet" => "bougé à Ambris-Bois au début du siècle",
        "code_insee_commune_actuelle" => "01235",
        "edifice_actuel" => "église Saint-Martin"
      )
    end
    let(:attributes) { obj.parse_row_to_objet_attributes(row) }
    it "le lieu de déplacement prend précédence" do
      expect(attributes[:palissy_INSEE]).to eq "01004"
      expect(attributes[:palissy_WEB]).to eq "01235"
      expect(attributes[:palissy_DEPL]).to eq "bougé à Ambris-Bois au début du siècle"
      expect(attributes[:palissy_MOSA]).to eq "église Saint-Martin"
      expect(attributes[:lieu_actuel_code_insee]).to eq "01235"
      expect(attributes[:lieu_actuel_edifice_nom]).to eq "église Saint-Martin"
      expect(attributes[:lieu_actuel_edifice_ref]).to eq nil
      expect(attributes[:lieu_actuel_departement_code]).to eq "01"
      # important : lieu_actuel_edifice_ref ne doit pas prendre la valeur de palissy_REFA !
    end
  end

  context "déplacement d’objet, ref merimée renseignée" do
    let(:row) do
      base_row.merge(
        "lieu_de_deplacement_de_l_objet" => "bougé à Ambris-Bois au début du siècle",
        "code_insee_commune_actuelle" => "01235",
        "edifice_actuel" => "église Saint-Martin ; PA00934057"
      )
    end
    let(:attributes) { obj.parse_row_to_objet_attributes(row) }
    it "le lieu de déplacement prend précédence" do
      expect(attributes[:palissy_INSEE]).to eq "01004"
      expect(attributes[:palissy_WEB]).to eq "01235"
      expect(attributes[:palissy_DEPL]).to eq "bougé à Ambris-Bois au début du siècle"
      expect(attributes[:palissy_MOSA]).to eq "église Saint-Martin ; PA00934057"
      expect(attributes[:lieu_actuel_code_insee]).to eq "01235"
      expect(attributes[:lieu_actuel_edifice_nom]).to eq "église Saint-Martin"
      expect(attributes[:lieu_actuel_edifice_ref]).to eq "PA00934057"
      expect(attributes[:lieu_actuel_departement_code]).to eq "01"
    end
  end
end
