# frozen_string_literal: true

require "rails_helper"

shared_examples "an accessible page" do
  it "should be axe clean" do
    expect(page).to be_axe_clean
  end
end

feature "public pages accessibility", js: true do
  describe "Liste des objets protégés de toute la France" do
    let!(:objets1) { create_list(:objet, 10, :with_image) }
    let!(:objets2) { create_list(:objet, 12, :without_image) }
    before { visit objets_path }
    it_behaves_like "an accessible page"
  end

  describe "Objets sans photo" do
    let!(:objet) { create(:objet, :without_image) }
    before { visit objet_path(objet) }
    it_behaves_like "an accessible page"
  end

  # "Liste des communes par département", departements_path
  # "Liste des communes du #{departement}", departement_path(departement)
  # "Liste des objets de #{commune}", objets_path(commune_code_insee: commune.code_insee)
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
end
