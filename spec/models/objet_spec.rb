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

  describe ".recensés" do
    let(:commune) { create(:commune, :en_cours_de_recensement) }
    let(:dossier) { commune.dossier }

    it "returns objets with active recensements" do
      objet_with_recensement = create(:objet, commune:)
      create(:recensement, objet: objet_with_recensement, dossier:)
      objet_without_recensement = create(:objet, commune:)

      result = Objet.recensés.to_a
      expect(result).to include(objet_with_recensement)
      expect(result).not_to include(objet_without_recensement)
    end

    it "excludes objets with only soft-deleted recensements" do
      objet_with_deleted_recensement = create(:objet, commune:)
      create(:recensement, :supprimé, objet: objet_with_deleted_recensement, dossier:)

      result = Objet.recensés.to_a
      expect(result).not_to include(objet_with_deleted_recensement)
    end

    it "includes objets when they have both active and deleted recensements from different dossiers" do
      objet_with_mixed_recensements = create(:objet, commune:)
      create(:recensement, objet: objet_with_mixed_recensements, dossier:)
      archived_dossier = create(:dossier, :archived, commune:)
      create(:recensement, :supprimé, objet: objet_with_mixed_recensements, dossier: archived_dossier)

      result = Objet.recensés.to_a
      expect(result).to include(objet_with_mixed_recensements)
    end

    it "returns distinct objets even with multiple recensements" do
      objet = create(:objet, commune:)
      create(:recensement, objet:, dossier:)
      archived_dossier = create(:dossier, :archived, commune:)
      create(:recensement, objet:, dossier: archived_dossier)

      result = Objet.recensés.to_a
      expect(result.count { |o| o.id == objet.id }).to eq(1)
    end
  end

  describe ".dans_départements_actifs" do
    it "returns objets in active départements only" do
      dept_actif = create(:departement, code: "01")
      dept_inactif = create(:departement, code: "02")
      create(:campaign, :ongoing, departement: dept_actif)

      commune_active = create(:commune, departement: dept_actif)
      commune_inactive = create(:commune, departement: dept_inactif)

      objet_active = create(:objet, commune: commune_active)
      objet_inactive = create(:objet, commune: commune_inactive)

      result = Objet.dans_départements_actifs.to_a
      expect(result).to include(objet_active)
      expect(result).not_to include(objet_inactive)
    end
  end

  describe ".recensés_dans_départements_actifs" do
    it "returns distinct recensed objets in active départements only" do
      dept_actif = create(:departement, code: "01")
      dept_inactif = create(:departement, code: "02")
      create(:campaign, :ongoing, departement: dept_actif)

      commune_active = create(:commune, departement: dept_actif)
      commune_inactive = create(:commune, departement: dept_inactif)

      objet1 = create(:objet, commune: commune_active)
      objet2 = create(:objet, commune: commune_active)
      objet3 = create(:objet, commune: commune_inactive)

      create(:recensement, objet: objet1)
      create(:recensement, objet: objet2)
      create(:recensement, objet: objet3)

      result = Objet.recensés_dans_départements_actifs.to_a
      expect(result).to include(objet1, objet2)
      expect(result).not_to include(objet3)
      expect(result.size).to eq(2)
    end

    it "combines the two scopes correctly" do
      dept_actif = create(:departement, code: "01")
      dept_inactif = create(:departement, code: "02")
      create(:campaign, :ongoing, departement: dept_actif)

      commune_active = create(:commune, departement: dept_actif)
      commune_inactive = create(:commune, departement: dept_inactif)

      objet_recensé_actif = create(:objet, commune: commune_active)
      objet_non_recensé_actif = create(:objet, commune: commune_active)
      objet_recensé_inactif = create(:objet, commune: commune_inactive)

      create(:recensement, objet: objet_recensé_actif)
      create(:recensement, objet: objet_recensé_inactif)

      result = Objet.recensés_dans_départements_actifs.to_a
      expect(result).to include(objet_recensé_actif)
      expect(result).not_to include(objet_non_recensé_actif, objet_recensé_inactif)
      expect(result.size).to eq(1)
    end
  end

  describe ".prioritaires" do
    let(:commune) { create(:commune, :en_cours_de_recensement) }
    let(:dossier) { commune.dossier }

    it "returns objets with recensements en peril" do
      objet_en_peril = create(:objet, commune:)
      objet_normal = create(:objet, commune:)

      create(:recensement, :en_peril, objet: objet_en_peril, dossier:)
      create(:recensement, :bon_etat, objet: objet_normal, dossier:)

      result = Objet.prioritaires.to_a
      expect(result).to include(objet_en_peril)
      expect(result).not_to include(objet_normal)
    end

    it "returns objets with recensements disparus" do
      objet_disparu = create(:objet, commune:)
      objet_normal = create(:objet, commune:)

      create(:recensement, :disparu, objet: objet_disparu, dossier:)
      create(:recensement, :bon_etat, objet: objet_normal, dossier:)

      result = Objet.prioritaires.to_a
      expect(result).to include(objet_disparu)
      expect(result).not_to include(objet_normal)
    end

    it "returns distinct objets even with multiple prioritaire recensements" do
      objet = create(:objet, commune:)
      create(:recensement, :en_peril, objet:, dossier:)
      archived_dossier = create(:dossier, :archived, commune:)
      create(:recensement, :disparu, objet:, dossier: archived_dossier)

      result = Objet.prioritaires.to_a
      expect(result.count { |o| o.id == objet.id }).to eq(1)
    end
  end

  describe ".analysés" do
    let(:commune) { create(:commune, :en_cours_de_recensement) }
    let(:dossier) { commune.dossier }
    let(:conservateur) { create(:conservateur) }

    it "returns objets with analysed recensements" do
      objet_analysé = create(:objet, commune:)
      objet_non_analysé = create(:objet, commune:)

      recensement_analysé = create(:recensement, objet: objet_analysé, dossier:)
      recensement_analysé.update!(analysed_at: Time.current, conservateur:)
      create(:recensement, objet: objet_non_analysé, dossier:)

      result = Objet.analysés.to_a
      expect(result).to include(objet_analysé)
      expect(result).not_to include(objet_non_analysé)
    end

    it "returns distinct objets even with multiple analysed recensements" do
      objet = create(:objet, commune:)
      recensement1 = create(:recensement, objet:, dossier:)
      recensement1.update!(analysed_at: Time.current, conservateur:)

      archived_dossier = create(:dossier, :archived, commune:)
      recensement2 = create(:recensement, objet:, dossier: archived_dossier)
      recensement2.update!(analysed_at: Time.current, conservateur:)

      result = Objet.analysés.to_a
      expect(result.count { |o| o.id == objet.id }).to eq(1)
    end
  end

  describe ".prioritaires.analysés.dans_départements_actifs" do
    it "combines all three scopes correctly" do
      dept_actif = create(:departement, code: "01")
      dept_inactif = create(:departement, code: "02")
      create(:campaign, :ongoing, departement: dept_actif)

      commune_active = create(:commune, departement: dept_actif)
      commune_inactive = create(:commune, departement: dept_inactif)
      dossier_actif = create(:dossier, :construction, commune: commune_active)
      dossier_inactif = create(:dossier, :construction, commune: commune_inactive)
      conservateur = create(:conservateur)

      # Objet prioritaire, analysé, département actif - INCLUDED
      objet_complet = create(:objet, commune: commune_active)
      rec1 = create(:recensement, :en_peril, objet: objet_complet, dossier: dossier_actif)
      rec1.update!(analysed_at: Time.current, conservateur:)

      # Objet prioritaire, non analysé, département actif - EXCLUDED
      objet_non_analysé = create(:objet, commune: commune_active)
      create(:recensement, :en_peril, objet: objet_non_analysé, dossier: dossier_actif)

      # Objet non prioritaire, analysé, département actif - EXCLUDED
      objet_non_prioritaire = create(:objet, commune: commune_active)
      rec3 = create(:recensement, :bon_etat, objet: objet_non_prioritaire, dossier: dossier_actif)
      rec3.update!(analysed_at: Time.current, conservateur:)

      # Objet prioritaire, analysé, département inactif - EXCLUDED
      objet_dept_inactif = create(:objet, commune: commune_inactive)
      rec4 = create(:recensement, :disparu, objet: objet_dept_inactif, dossier: dossier_inactif)
      rec4.update!(analysed_at: Time.current, conservateur:)

      result = Objet.prioritaires.analysés.dans_départements_actifs.to_a
      expect(result).to include(objet_complet)
      expect(result).not_to include(objet_non_analysé, objet_non_prioritaire, objet_dept_inactif)
      expect(result.size).to eq(1)
    end
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
