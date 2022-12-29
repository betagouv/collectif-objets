# frozen_string_literal: true

require "rails_helper"

shared_examples "an accessible page" do
  it "should be axe clean" do
    expect(page).to be_axe_clean
  end
end

feature "public pages accessibility", js: true do
  describe "objets#index" do
    let!(:objets1) { create_list(:objet, 10, :with_image) }
    let!(:objets2) { create_list(:objet, 12, :without_image) }
    before { visit objets_path }
    it_behaves_like "an accessible page"
  end

  describe "objets#show sans photo" do
    let!(:objet) { create(:objet, :without_image) }
    before { visit objet_path(objet) }
    it_behaves_like "an accessible page"
  end

  describe "objets#show avec photo" do
    let!(:objet) { create(:objet, :with_image) }
    before { visit objet_path(objet) }
    it_behaves_like "an accessible page"
  end

  describe "departements#index - Liste des communes de toute la france" do
    before do
      departements = create_list(:departement, 2)
      departements.each { create_list(:commune, 2, departement: _1) }
    end
    before { visit departements_path }
    it_behaves_like "an accessible page"
  end

  describe "departements#show - Liste des communes d'un département" do
    let!(:departement) { create(:departement) }
    let!(:communes) { create_list(:commune, 2, departement:) }
    let!(:objets) do
      communes.map { create_list(:objet, 3, commune: _1) }.flatten
    end
    before { visit departement_path(departement) }
    it_behaves_like "an accessible page"
  end

  describe "objets#index(commune_code_insee) - Liste des objets d'une commune" do
    let!(:commune) { create(:commune) }
    let!(:objets) { create_list(:objet, 3, commune:) }
    before { visit objets_path(commune_code_insee: commune.code_insee) }
    it_behaves_like "an accessible page"
  end

  # "Statistiques", :stats_path

  context "Connexion page" do
    before { visit connexion_path }
    it_behaves_like "an accessible page"
  end

  describe "Connexion Communes" do
    before { visit new_user_session_path }
    it_behaves_like "an accessible page"
  end

  describe "Connexion Conservateur" do
    before { visit new_conservateur_session_path }
    it_behaves_like "an accessible page"
  end

  describe "Connexion Administrateur" do
    before { visit new_admin_user_session_path }
    it_behaves_like "an accessible page"
  end

  describe "Ils parlent de nous" do
    before { visit presse_path }
    it_behaves_like "an accessible page"
  end

  describe "Conditions générales d'utilisation" do
    before { visit conditions_path }
    it_behaves_like "an accessible page"
  end

  describe "Mentions Légales" do
    before { visit mentions_legales_path }
    it_behaves_like "an accessible page"
  end

  describe "Confidentialité" do
    before { visit confidentialite_path }
    it_behaves_like "an accessible page"
  end

  describe "Comment ça marche ?" do
    before { visit aide_path }
    it_behaves_like "an accessible page"
  end

  describe "Guide du recensement" do
    before { visit guide_path }
    it_behaves_like "an accessible page"
  end

  describe "Plan du site" do
    before { visit plan_path }
    it_behaves_like "an accessible page"
  end

  describe "Fiches conseil" do
    before { visit fiches_path }
    it_behaves_like "an accessible page"
  end

  describe "Fiche conseil vol" do
    before { visit fiche_path(pdf: "fiche_vol") }
    it_behaves_like "an accessible page"
  end
end
