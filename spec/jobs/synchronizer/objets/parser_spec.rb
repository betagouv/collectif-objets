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
      "typologie_de_la_protection" => "classé au titre objet"
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
    end
  end
end
