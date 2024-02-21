# frozen_string_literal: true

require "rails_helper"

RSpec.describe Synchronizer::Objets::Row do
  subject { row }
  let(:base_attributes) do
    {
      "cog_insee" => "12345",
      "typologie_du_dossier" => "dossier individuel",
      "statut_juridique_de_l_objet" => "",
      "statut_juridique_du_proprietaire" => "propriété de la commune",
      "titre_editorial" => "Joli tableau"
    }
  end
  let(:row) { described_class.new(base_attributes.merge(row_attributes)) }
  before { row.valid? } # trigger validations

  describe "scope cog_insee (INSEE)" do
    context "quand le champ est bien rempli" do
      let(:row_attributes) { { "cog_insee" => "12345" } }
      it { should be_in_scope }
    end

    context "quand le champ est nil" do
      let(:row_attributes) { { "cog_insee" => nil } }
      it { should_not be_in_scope }
      it "a un message d’erreur correct" do
        expect(row.out_of_scope_message).to eq("la notice n’a pas de code INSEE")
      end
    end

    context "quand le champ est blank" do
      let(:row_attributes) { { "cog_insee" => "" } }
      it { should_not be_in_scope }
      it "a un message d’erreur correct" do
        expect(row.out_of_scope_message).to eq("la notice n’a pas de code INSEE")
      end
    end
  end

  describe "scope typologie_du_dossier (DOSS)" do
    context "quand le champ est nil" do
      let(:row_attributes) { { "typologie_du_dossier" => nil } }
      it { should_not be_in_scope }
      it "a un message d’erreur correct" do
        expect(row.out_of_scope_message).to eq("la notice ne correspond pas à un dossier individuel")
      end
    end

    context "quand le champ est blank" do
      let(:row_attributes) { { "typologie_du_dossier" => "" } }
      it { should_not be_in_scope }
      it "a un message d’erreur correct" do
        expect(row.out_of_scope_message).to eq("la notice ne correspond pas à un dossier individuel")
      end
    end

    context "quand c’est un dossier individuel" do
      let(:row_attributes) { { "typologie_du_dossier" => "dossier individuel" } }
      it { should be_in_scope }
    end

    context "quand le dossier est hors scope" do
      let(:row_attributes) { { "typologie_du_dossier" => "sous-dossier" } }
      it { should_not be_in_scope }
      it "a un message d’erreur correct" do
        expect(row.out_of_scope_message).to eq("la notice ne correspond pas à un dossier individuel")
      end
    end
  end

  describe "scope statut_juridique_de_l_objet (MANQUANT)" do
    context "quand statut_juridique_de_l_objet est nil" do
      let(:row_attributes) { { "statut_juridique_de_l_objet" => nil } }
      it { should be_in_scope }
    end

    context "quand statut_juridique_de_l_objet est blank" do
      let(:row_attributes) { { "statut_juridique_de_l_objet" => "" } }
      it { should be_in_scope }
    end

    context "quand l’objet est manquant" do
      let(:row_attributes) { { "statut_juridique_de_l_objet" => "manquant" } }

      it { should_not be_in_scope }
      it "a un message d’erreur correct" do
        expect(row.out_of_scope_message).to eq("l’objet est manquant ou volé")
      end
    end

    context "quand l’objet est volé" do
      let(:row_attributes) { { "statut_juridique_de_l_objet" => "volé" } }
      it { should_not be_in_scope }
      it "a un message d’erreur correct" do
        expect(row.out_of_scope_message).to eq("l’objet est manquant ou volé")
      end
    end
  end

  describe "scope titre_editorial (TICO)" do
    context "quand le champ est nil" do
      let(:row_attributes) { { "titre_editorial" => nil } }
      it { should be_in_scope }
    end

    context "quand le champ est blank" do
      let(:row_attributes) { { "titre_editorial" => "" } }
      it { should be_in_scope }
    end

    context "quand le titre_editorial est normal" do
      let(:row_attributes) { { "titre_editorial" => "Joli tableau" } }
      it { should be_in_scope }
    end

    context "quand la notice est en cours de traitement" do
      let(:row_attributes) { { "titre_editorial" => "Traitement en cours" } }

      it { should_not be_in_scope }
      it "a un message d’erreur correct" do
        expect(row.out_of_scope_message).to eq("la notice est en cours de traitement")
      end
    end
  end

  describe "scope statut_juridique_du_proprietaire (STAT)" do
    context "quand le champ est blank" do
      let(:row_attributes) { { "statut_juridique_du_proprietaire" => "" } }
      it { should be_in_scope }
    end

    context "quand le champ est nil" do
      let(:row_attributes) { { "statut_juridique_du_proprietaire" => nil } }
      it { should be_in_scope }
    end

    context "quand c’est la propriété de la commune" do
      let(:row_attributes) { { "statut_juridique_du_proprietaire" => "propriété de la commune" } }
      it { should be_in_scope }
    end

    context "quand statut_juridique_du_proprietaire est hors scope" do
      let(:row_attributes) { { "statut_juridique_du_proprietaire" => "propriété de l'Etat" } }

      it { should_not be_in_scope }
      it "a un message d’erreur correct" do
        expect(row.out_of_scope_message).to eq("l’objet est propriété de l’État")
      end
    end
  end

  describe "classé/déclassé" do
    [
      "2003/03/03 : classé au titre objet",
      "2023/12/18 : classé comme un ensemble historique mobilier",
      "2023/09/26 : inscrit au titre objet",
      "1937/04/09 : déclassé ; 1911/09/30 : classé au titre objet",
      "1988/08/25 : inscrit au titre objet ; 1988/09/15 : inscrit au titre objet",
      ""
    ].each do |dprot|
      context "quand date_et_typologie_de_la_protection est #{dprot}" do
        let(:row_attributes) { { "date_et_typologie_de_la_protection" => dprot } }
        it { should be_in_scope }
      end
    end

    [
      "déclassé",
      "1911 : déclassé",
      "1994/09/22 : déclassé",
      "1907/07/30 : classé au titre objet ; déclassé",
      "1910/05/02 : classé au titre objet ; 1933/02/24 : déclassé"
    ].each do |dprot|
      context "quand date_et_typologie_de_la_protection est #{dprot}" do
        let(:row_attributes) { { "date_et_typologie_de_la_protection" => dprot } }
        it { should_not be_in_scope }

        it "a un message d’erreur correct" do
          expect(row.out_of_scope_message).to eq("l’objet est déclassé")
        end
      end
    end
  end
end
