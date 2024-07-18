# frozen_string_literal: true

require "rails_helper"

RSpec.describe Exports::Mpp, type: :model do
  let(:commune) { create(:commune, :en_cours_de_recensement) }

  context "::Deplaces" do
    let(:exporter) { Exports::Mpp::Deplaces }
    describe "#objets" do
      it "liste les objets" do
        create(:objet, commune:)
        create(:objet, :disparu, commune:)
        objets = create_list(:objet, 3, :deplace_et_examine, commune:)
        expect(exporter.objets.order(:created_at)).to eq objets
      end
    end
    describe "#values(objet)" do
      it "liste les valeurs d'un objet" do
        objet = create(:objet, :deplace_et_examine, commune:)
        lieu_de_deplacement = [
          objet.nouveau_departement&.region || objet.departement&.region,
          objet.nouveau_departement&.code || objet.departement.code,
          objet.nouvelle_commune&.nom || objet.commune&.nom,
          "#{objet.nouvel_edifice} (Collectif Objets #{objet.recensement.analysed_at.year})"
        ].join(" ; ")
        expectation = [
          objet.palissy_REF,
          objet.departement.nom,
          objet.palissy_INSEE,
          objet.commune.nom,
          objet.edifice&.nom&.upcase_first,
          objet.nouveau_departement&.nom || objet.departement.nom,
          objet.lieu_actuel_code_insee,
          objet.nouvel_edifice&.upcase_first,
          I18n.l(objet.recensement.analysed_at, format: :long).upcase_first,
          objet.nouveau_departement&.region || objet.departement.region,
          objet.nouvelle_commune&.nom,
          "Lieu de déplacement : #{lieu_de_deplacement}"
        ]
        expect(exporter.values(objet)).to eq expectation
      end
    end
  end

  context "::Manquants" do
    let(:exporter) { Exports::Mpp::Manquants }
    describe "#objets" do
      it "liste les objets" do
        create(:objet, commune:)
        create(:objet, :deplace, commune:)
        objets = create_list(:objet, 3, :disparu_et_examine, commune:)
        expect(exporter.objets.order(:created_at)).to eq objets
      end
    end
    describe "#values(objet)" do
      it "liste les valeurs d'un objet" do
        objet = create(:objet, :disparu_et_examine, commune:)
        expectation = [
          objet.palissy_REF,
          objet.departement.nom,
          objet.lieu_actuel_code_insee,
          objet.recensement.notes,
          objet.recensement.dossier.notes_commune,
          objet.recensement.dossier.notes_conservateur,
          objet.recensement.analyse_notes,
          I18n.l(objet.recensement.analysed_at, format: :long).upcase_first,
          "Manquant",
          "Œuvre déclarée manquante au moment du recensement Collectif Objets en #{objet.recensement.analysed_at.year}"
        ]
        expect(exporter.values(objet)).to eq expectation
      end
    end
  end
end
