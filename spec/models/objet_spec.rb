# frozen_string_literal: true

require "rails_helper"

RSpec.describe Objet, type: :model do
  it "filtre les objets inscrits et classés au patrimoine" do
    create(:objet, palissy_PROT: "1993/01/11 : inscrit au titre objet") # inscrit
    create(:objet, palissy_PROT: "classé au ti") # classé
    create(:objet, palissy_PROT: "classé au titre") # classé
    create(:objet, palissy_PROT: "classé au titre ensemble historique mobilier") # classé
    create(:objet, palissy_PROT: "classé au titre immeuble") # classé
    create(:objet, palissy_PROT: "classé au titre immeuble ; classé au titre objet") # classé
    create(:objet, palissy_PROT: "classé au titre immeuble ; classé au titre objet ; classé au titre objet") # classé
    create(:objet, palissy_PROT: "classé au titre immeuble ; inscrit au titre objet") # mis de côté
    create(:objet, palissy_PROT: "classé  au titre objet") # classé
    create(:objet, palissy_PROT: "classé au  titre objet") # classé
    create(:objet, palissy_PROT: "classé au titre objet") # classé
    create(:objet, palissy_PROT: "classé au titre objet ") # classé
    create(:objet, palissy_PROT: "classé au titre objet (?)") # classé
    create(:objet, palissy_PROT: "classé au titre objet.") # classé
    create(:objet, palissy_PROT: "Classé au titre objet") # classé
    create(:objet, palissy_PROT: "classé au titre objet ; classé au titre immeuble") # classé
    create(:objet, palissy_PROT: "classé au titre objet ; classé au titre objet") # classé
    create(:objet, palissy_PROT: "classé au titre objet ; classé au titre objet ; classé au titre objet") # classé
    create(:objet, palissy_PROT: "classé au titre objet ; classé au titre objet ; inscrit au titre objet") # mis de côté
    create(:objet, palissy_PROT: "classé au titre objet ; inscrit au titre immeuble") # mis de côté
    create(:objet, palissy_PROT: "classé au titre objet ; inscrit au titre objet") # mis de côté
    create(:objet, palissy_PROT: "classé au titre objet ; inscrit au titre objet partiellement") # mis de côté
    create(:objet, palissy_PROT: "classé au titre objet partiellement") # classé
    create(:objet, palissy_PROT: "classé comme ensemble historique mobilier") # classé
    create(:objet, palissy_PROT: "classé comme un ensemble historique mobilier") # classé
    create(:objet, palissy_PROT: "classé MH") # classé
    create(:objet, palissy_PROT: "classé MH ; classé au titre objet") # classé
    create(:objet, palissy_PROT: "classé Monument Historique") # classé
    create(:objet, palissy_PROT: "déclassé au titre objet") # mis de côté
    create(:objet, palissy_PROT: "désinscrit") # mis de côté
    create(:objet, palissy_PROT: "devenu non protégé") # mis de côté
    create(:objet, palissy_PROT: "fleur") # mis de côté
    create(:objet, palissy_PROT: "i") # mis de côté
    create(:objet, palissy_PROT: "immeuble par nature") # mis de côté
    create(:objet, palissy_PROT: "inscr") # inscrit
    create(:objet, palissy_PROT: "inscri") # inscrit
    create(:objet, palissy_PROT: "inscrit") # inscrit
    create(:objet, palissy_PROT: "inscrit au") # inscrit
    create(:objet, palissy_PROT: "inscrit au ") # inscrit
    create(:objet, palissy_PROT: "inscrit au t") # inscrit
    create(:objet, palissy_PROT: "inscrit au tit") # inscrit
    create(:objet, palissy_PROT: "inscrit au titr") # inscrit
    create(:objet, palissy_PROT: "inscrit au titre") # inscrit
    create(:objet, palissy_PROT: "inscrit au titre des Monuments historiques") # inscrit
    create(:objet, palissy_PROT: "inscrit au titre immeuble") # inscrit
    create(:objet, palissy_PROT: "inscrit au titre obejt") # inscrit
    create(:objet, palissy_PROT: "inscrit au titre obje") # inscrit
    create(:objet, palissy_PROT: " inscrit au titre objet") # inscrit
    create(:objet, palissy_PROT: "\ninscrit au titre objet") # inscrit
    create(:objet, palissy_PROT: "inscrit au titre objet") # inscrit
    create(:objet, palissy_PROT: "inscrit au titre objet (?)") # inscrit
    create(:objet, palissy_PROT: "Inscrit au titre objet") # inscrit
    create(:objet, palissy_PROT: "inscrit au titre objet ; classé au titre immeuble") # mis de côté
    create(:objet, palissy_PROT: "inscrit au titre objet ; classé au titre objet") # mis de côté
    create(:objet, palissy_PROT: "inscrit au titre objet : classé au titre objet") # mis de côté
    create(:objet, palissy_PROT: "inscrit au titre objet ; classé au titre objet ; classé au titre objet") # mis de côté
    create(:objet, palissy_PROT: "inscrit au titre objet ; classé au titre objet partiellement") # mis de côté
    create(:objet, palissy_PROT: "Inscrit au titre objet") # inscrit
    create(:objet, palissy_PROT: "inscrit au titre objet ; inscrit au titre immeuble") # inscrit
    create(:objet, palissy_PROT: "inscrit au titre objet ; inscrit au titre objet") # inscrit
    create(:objet, palissy_PROT: "inscrit au titre objet ; inscrit au titre objet partiellement (?)") # inscrit
    create(:objet, palissy_PROT: "inscrit au titre objet partiellement") # inscrit
    create(:objet, palissy_PROT: "inscrit au titre objet partiellement ; classé au titre objet partiellement") # mis de côté
    create(:objet, palissy_PROT: "inscrite au titre objet") # inscrit
    create(:objet, palissy_PROT: "inscrit MH") # inscrit
    create(:objet, palissy_PROT: "non protégé") # mis de côté
    create(:objet, palissy_PROT: "non protégé ?") # mis de côté
    create(:objet, palissy_PROT: "sans protection") # mis de côté

    expect(Objet.classés.count).to eq(22)
    expect(Objet.inscrits.count).to eq(26)
  end
end
