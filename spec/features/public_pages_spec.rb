# frozen_string_literal: true

require "rails_helper"

feature "accessibility public pages", js: true do
  subject { page }

  describe "page d'accueil" do
    before { visit root_path }
    it { should be_axe_clean.excluding("iframe") }
  end

  describe "communes#show" do
    let!(:commune) { create(:commune, :with_objets) }
    before { visit commune_path(commune) }
    it { should be_axe_clean }
  end

  # "Statistiques", :stats_path

  describe "Connexion Communes" do
    before { visit new_user_session_code_path }
    it { should be_axe_clean }
  end

  describe "Connexion Conservateur" do
    before { visit new_conservateur_session_path }
    it { should be_axe_clean }
  end

  describe "Connexion Administrateur" do
    before { visit new_admin_user_session_path }
    it { should be_axe_clean }
  end

  describe "On parle de nous" do
    before { visit presse_path }
    it { should be_axe_clean.excluding("iframe") }
  end

  ArticlePresse.load_all.each do |article_presse|
    describe "Article de Presse #{article_presse.title}" do
      before { visit article_presse_path(article_presse.id) }
      it { should be_axe_clean.excluding("iframe") }
    end
  end

  describe "Conditions générales d'utilisation" do
    before { visit conditions_path }
    it { should be_axe_clean }
  end

  describe "Mentions Légales" do
    before { visit mentions_legales_path }
    it { should be_axe_clean }
  end

  describe "Confidentialité" do
    before { visit confidentialite_path }
    it { should be_axe_clean }
  end

  describe "Comment ça marche ?" do
    before { visit aide_path }
    it { should be_axe_clean }
  end

  describe "Guide du recensement" do
    before do
      url = Regexp.new(Regexp.escape(PagesController::STATIC_FILES_HOST))
      stub_request(:any, url).to_return(status: 200, body: "", headers: {})
      visit guide_path
    end
    it { should be_axe_clean }
  end

  describe "Plan du site" do
    before { visit plan_path }
    it { should be_axe_clean }
  end

  describe "Schéma pluriannuel d’accessibilité" do
    before { visit schema_pluriannuel_accessibilite_path }
    it { should be_axe_clean }
  end

  describe "Déclaration d’accessibilité" do
    before { visit declaration_accessibilite_path }
    it { should be_axe_clean }
  end

  describe "Fiches conseil" do
    before { visit fiches_path }
    it { should be_axe_clean }
  end

  Fiche.load_all.each do |fiche|
    describe "Fiche conseil #{fiche.title}" do
      before { visit fiche_path(fiche.id) }
      it { should be_axe_clean }
    end
  end

  describe "Documentation conservateur" do
    before { visit content_blob_path(:documentation_conservateur) }
    it { should be_axe_clean.excluding("iframe") }
  end

  describe "Documentation commune" do
    before { visit content_blob_path(:aide_en_ligne) }
    it { should be_axe_clean.excluding("iframe") }
  end

  describe "Page d’accueil conservateurs" do
    before { visit accueil_conservateurs_path }
    it { should be_axe_clean.excluding("iframe") }
  end
end
