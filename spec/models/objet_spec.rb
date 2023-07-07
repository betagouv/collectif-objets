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
end
