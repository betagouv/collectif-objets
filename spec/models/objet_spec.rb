# frozen_string_literal: true

require "rails_helper"

RSpec.describe Objet, type: :model do
  it "filtre les objets inscrits et classés au patrimoine" do
    objets_considérés_comme_classés = [
      "classé au ti",
      "classé au titre",
      "classé au titre ensemble historique mobilier",
      "classé au titre immeuble",
      "classé au titre immeuble ; classé au titre objet",
      "classé au titre immeuble ; classé au titre objet ; classé au titre objet",
      "classé  au titre objet",
      "classé au  titre objet",
      "classé au titre objet",
      "classé au titre objet ",
      "classé au titre objet (?)",
      "classé au titre objet.",
      "Classé au titre objet",
      "classé au titre objet ; classé au titre immeuble",
      "classé au titre objet ; classé au titre objet",
      "classé au titre objet ; classé au titre objet ; classé au titre objet",
      "classé au titre objet partiellement",
      "classé comme ensemble historique mobilier",
      "classé comme ensemble historique mobilier",
      "classé MH",
      "classé MH ; classé au titre objet",
      "classé Monument Historique",
      "classé au titre immeuble ; inscrit au titre objet",
      "classé au titre objet ; classé au titre objet ; inscrit au titre objet",
      "classé au titre objet ; inscrit au titre immeuble",
      "classé au titre objet ; inscrit au titre objet",
      "classé au titre objet ; inscrit au titre objet partiellement",
      "inscrit au titre objet ; classé au titre immeuble",
      "inscrit au titre objet ; classé au titre objet",
      "inscrit au titre objet : classé au titre objet",
      "inscrit au titre objet ; classé au titre objet ; classé au titre objet",
      "inscrit au titre objet ; classé au titre objet partiellement",
      "inscrit au titre objet ; classé au titre objet partiellement",
      "inscrit au titre objet partiellement ; classé au titre objet partiellement"
    ]
    objets_considérés_comme_inscrits = [
      "1993/01/11 : inscrit au titre objet",
      "inscr",
      "inscri",
      "inscrit",
      "inscrit au",
      "inscrit au ",
      "inscrit au t",
      "inscrit au tit",
      "inscrit au titr",
      "inscrit au titre",
      "inscrit au titre des Monuments historiques",
      "inscrit au titre immeuble",
      "inscrit au titre obejt",
      "inscrit au titre obje",
      " inscrit au titre objet",
      "\ninscrit au titre objet",
      "inscrit au titre objet",
      "inscrit au titre objet (?)",
      "Inscrit au titre objet",
      "inscrit au titre objet ; inscrit au titre immeuble",
      "inscrit au titre objet ; inscrit au titre objet",
      "inscrit au titre objet ; inscrit au titre objet partiellement (?)",
      "inscrit au titre objet partiellement",
      "inscrite au titre objet",
      "inscrit MH"
    ]
    objets_mis_à_part = [
      "déclassé au titre objet",
      "désinscrit",
      "devenu non protégé",
      "fleur",
      "i",
      "immeuble par nature",
      "non protégé",
      "non protégé ?",
      "sans protection"
    ]
    tous_les_objets = objets_considérés_comme_classés + objets_considérés_comme_inscrits + objets_mis_à_part

    build_list(:objet, tous_les_objets.size) do |objet, index|
      objet.palissy_PROT = tous_les_objets[index]
      objet.save
    end

    expect(Objet.classés.count).to eq(objets_considérés_comme_classés.size)
    expect(Objet.inscrits.count).to eq(objets_considérés_comme_inscrits.size)
    expect(Objet.protégés.count).to eq(objets_considérés_comme_classés.size + objets_considérés_comme_inscrits.size)
  end

  it ".order_by_recensement_priorite" do
    commune = create(:commune, :en_cours_de_recensement)
    dossier = commune.dossier
    objet_recensé_vert = create(:objet, commune:)
    create(:recensement, objet: objet_recensé_vert, dossier:)
    objet_recensé_prioritaire = create(:objet, commune:)
    create(:recensement, :en_peril, objet: objet_recensé_prioritaire, dossier:)
    objet_examiné = create(:objet, commune:)
    create(:recensement_examiné, objet: objet_examiné, dossier:)
    dossier_archivé = create(:dossier, :archived, commune:)
    create(:recensement_examiné, objet: objet_examiné, dossier: dossier_archivé)

    objets_ordered_by_priorite = Objet.order_by_recensement_priorite
    expect(objets_ordered_by_priorite.count).to eq 3
    expect(objets_ordered_by_priorite[0]).to eq(objet_recensé_prioritaire)
    expect(objets_ordered_by_priorite[1]).to eq(objet_recensé_vert)
    expect(objets_ordered_by_priorite[2]).to eq(objet_examiné)
  end

  it ".without_completed_recensements" do
    commune = create(:commune, :en_cours_de_recensement)
    dossier = commune.dossier
    create(:objet, commune:)
    objet_recensé_brouillon = create(:objet, commune:)
    create(:recensement, status: :draft, objet: objet_recensé_brouillon, dossier:)
    objet_recensé = create(:objet, commune:)
    create(:recensement, objet: objet_recensé, dossier:)

    expect(Objet.without_completed_recensements.count).to eq 2
  end

  describe "#destroy_and_soft_delete_recensement!" do
    let!(:objet) { create(:objet) }
    let(:reason) { "objet-devenu-hors-scope" }
    let(:message) { "notice Palissy est un sous-dossier" }
    subject { objet.destroy_and_soft_delete_recensement!(reason:, message:) }

    context "quand il n'y a aucun recensement" do
      it "détruit l'objet" do
        subject
        expect { objet.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "quand un recensement completed existe" do
      let(:recensement) { create(:recensement) }
      let(:objet) { recensement.objet }
      it "l'objet est détruit et le recensement est soft-deleted" do
        subject
        expect { objet.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(recensement.reload.deleted?).to eq true
        expect(recensement.reload.deleted_at).to be_within(1.second).of(Time.zone.now)
        expect(recensement.reload.deleted_reason).to eq "objet-devenu-hors-scope"
        expect(recensement.reload.deleted_message).to eq "notice Palissy est un sous-dossier"
      end

      context "mais que objet.destroy! échoue" do
        before do
          allow(objet).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed)
        end
        it "ne supprime ni l'objet ni le recensement" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)
          expect(recensement.reload.deleted?).to eq false
        end
      end
    end
  end

  describe "#edifice_nom_formatted" do
    subject(:edifice_nom_formatted) { objet.edifice_nom_formatted }

    let(:objet) { build(:objet, edifice_nom:, commune: build(:commune, nom: "<Ville>")) }

    {
      nil => nil,
      "" => nil,
      "église" => "Une église de <Ville>",
      "HOTEL-DIEU" => "HOTEL-DIEU"
    }.each do |nom, expected_string|
      context "when edifice_nom is '#{nom || 'nil'}'" do
        let(:edifice_nom) { nom }
        it "renvoie '#{expected_string || 'nil'}'" do
          expect(edifice_nom_formatted).to eq(expected_string)
        end
      end
    end
  end
end
