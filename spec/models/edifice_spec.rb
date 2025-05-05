# frozen_string_literal: true

require "rails_helper"

RSpec.describe Edifice, type: :model do
  describe ".with_objets_classés_ou_inscrits" do
    it "filtre les edifices avec des objets classés ou inscrits" do
      edifice_sans_objets_classés_ou_inscrits = create(:edifice)
      edifice_avec_objets_classés_ou_inscrits = create(:edifice)

      create(:objet, palissy_PROT: "inscrit au titre objet", edifice: edifice_avec_objets_classés_ou_inscrits)
      create(:objet, palissy_PROT: "classé au titre objet", edifice: edifice_avec_objets_classés_ou_inscrits)
      create(:objet, palissy_PROT: "classé au titre objet ; classé au titre objet",
                     edifice: edifice_avec_objets_classés_ou_inscrits)
      create(:objet, palissy_PROT: "désinscrit", edifice: edifice_sans_objets_classés_ou_inscrits)

      expect(Edifice.with_objets_classés_ou_inscrits.count).to eq({ edifice_avec_objets_classés_ou_inscrits.id => 3 })
    end
  end

  describe ".normalize_nom" do
    subject(:normalized) { Edifice.normalize_nom(nom) }

    {
      nil => nil,
      "   " => nil,
      " église" => "Église"
    }.each do |nom, expectation|
      context "when nom is '#{nom || 'nil'}'" do
        let(:nom) { nom }
        it "renvoie '#{expectation || 'nil'}'" do
          expect(normalized).to eq(expectation)
        end
      end
    end
  end
end
