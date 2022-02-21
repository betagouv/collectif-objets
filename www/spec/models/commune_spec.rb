# frozen_string_literal: true

require "rails_helper"

RSpec.describe Commune, type: :model do
  describe "#main_objet" do
    let!(:commune) { create(:commune) }

    subject { commune.main_objet }
    context "some objet has image" do
      let!(:objet_without_image) { create(:objet, :without_image, commune:) }
      let!(:objet_with_image) { create(:objet, :with_image, commune:) }
      it { should eq objet_with_image }
    end
    context "none objets has image" do
      let!(:objet_without_image1) { create(:objet, :without_image, commune:, nom: "Statue de Jules Verne") }
      let!(:objet_without_image2) { create(:objet, :without_image, commune:, nom: "nom; pas terrible") }
      it { should eq objet_without_image1 }
    end
    context "no objets at all" do
      it { should eq nil }
    end
  end
end
