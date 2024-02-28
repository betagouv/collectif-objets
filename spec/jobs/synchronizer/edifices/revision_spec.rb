# frozen_string_literal: true

require "rails_helper"

describe Synchronizer::Edifices::Revision do
  subject { Synchronizer::Edifices::Revision.new(edifice_attributes).synchronize }

  context "mise à jour du nom d’un édifice retrouvé par sa REF" do
    let!(:edifice) { create(:edifice, merimee_REF: "PA00100001", nom: "Église Saint-Martin", code_insee: "01234") }
    let(:edifice_attributes) do
      {
        merimee_REF: "PA00100001",
        nom: "Église St Martin (ancien)",
        code_insee: "01234"
      }
    end
    it "should work" do
      subject
      expect(edifice.reload.nom).to eq("Église St Martin (ancien)")
    end
  end

  context "mise à jour du nom et de la ref d’un édifice retrouvé par son slug" do
    let!(:edifice) do
      create(:edifice, merimee_REF: nil, slug: "eglise-saint-martin", nom: "Église Saint-Martin", code_insee: "01234")
    end
    let(:edifice_attributes) do
      {
        merimee_REF: "PA00100001",
        nom: "Église Saint Martin", # tiret devient espace
        code_insee: "01234",
        slug: "eglise-saint-martin"
      }
    end
    it "should work" do
      subject
      expect(edifice.reload.nom).to eq("Église Saint Martin")
      expect(edifice.reload.merimee_REF).to eq("PA00100001")
    end
  end

  context "deux édifices préexistants et la MàJ générerait un doublon" do
    let!(:edifice_with_ref) do
      create(
        :edifice,
        merimee_REF: "PA00100001",
        slug: "eglise-saint-martin",
        nom: "Église Saint-Martin",
        code_insee: "01234"
      )
    end

    let!(:edifice_with_slug) do
      create(
        :edifice,
        merimee_REF: nil,
        slug: "eglise-saint-martin",
        nom: "Église Saint-Martin",
        code_insee: "43210"
      )
    end

    let(:edifice_attributes) do
      {
        merimee_REF: "PA00100001",
        nom: "Église Saint Martin",
        code_insee: "43210",
        slug: "eglise-saint-martin"
      }
    end

    it "should merge the two edifices" do
      subject
      expect(edifice_with_ref.reload.nom).to eq("Église Saint Martin")
      expect(edifice_with_ref.reload.code_insee).to eq("43210")
      expect { edifice_with_slug.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
