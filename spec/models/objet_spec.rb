# frozen_string_literal: true

require "rails_helper"

RSpec.describe Objet, type: :model do
  it "doit filtrer les objets inscrits et classés au patrimoine" do
    create(:objet, palissy_PROT: "inscrit au titre objet")
    create(:objet, palissy_PROT: "classé au titre objet")
    create(:objet, palissy_PROT: "classé au titre objet ; classé au titre objet")
    create(:objet, palissy_PROT: "désinscrit")
    # create(:objet, palissy_PROT: "classé au titre immeuble")

    expect(Objet.classés.count).to eq(2)
    expect(Objet.inscrits.count).to eq(1)
  end
end
