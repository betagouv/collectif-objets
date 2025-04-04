# frozen_string_literal: true

require "rails_helper"

feature "accessibility public pages", js: true do
  subject { page }

  shared_examples "an accessible page" do |excludes|
    it "should be accessible" do
      visit path
      expect(page).to have_current_path(path)
      expect(page.title).not_to eq("Collectif Objets") # Le titre par défaut
      expect(page).to be_axe_clean.excluding(*excludes)
    end
  end

  describe "page d'accueil" do
    let(:path) { root_path }

    it "should be accessible" do
      visit path
      expect(page).to have_current_path(path)
      expect(page).to be_axe_clean.excluding(:iframe)
    end
  end

  describe "communes#show" do
    let(:commune) { create(:commune, :with_objets) }
    let(:path) { commune_path(commune) }
    it_behaves_like "an accessible page"
  end

  # "Statistiques", :stats_path

  describe "Connexion Communes" do
    let(:path) { new_user_session_code_path }
    it_behaves_like "an accessible page"
  end

  describe "Connexion Conservateur" do
    let(:path) { new_conservateur_session_path }
    it_behaves_like "an accessible page"
  end

  describe "Connexion Administrateur" do
    let(:path) { new_admin_user_session_path }
    it_behaves_like "an accessible page"
  end

  describe "On parle de nous" do
    let(:path) { presse_path }
    it_behaves_like "an accessible page", :iframe
  end

  ArticlePresse.find_each do |article_presse|
    describe "Article de Presse #{article_presse.title}" do
      let(:path) { article_presse_path(article_presse.id) }
      it_behaves_like "an accessible page", :iframe
    end
  end

  describe "Conditions générales d'utilisation" do
    let(:path) { conditions_path }
    it_behaves_like "an accessible page"
  end

  describe "Mentions Légales" do
    let(:path) { mentions_legales_path }
    it_behaves_like "an accessible page"
  end

  describe "Confidentialité" do
    let(:path) { confidentialite_path }
    it_behaves_like "an accessible page"
  end

  describe "Comment ça marche ?" do
    let(:path) { aide_path }
    it_behaves_like "an accessible page"
  end

  describe "Guide du recensement" do
    let(:path) { guide_path }
    before do
      url = Regexp.new(Regexp.escape(PagesController::STATIC_FILES_HOST))
      stub_request(:any, url).to_return(status: 200, body: "", headers: {})
    end
    it_behaves_like "an accessible page"
  end

  describe "Plan du site" do
    let(:path) { plan_path }
    it_behaves_like "an accessible page"
  end

  describe "Schéma pluriannuel d’accessibilité" do
    let(:path) { schema_pluriannuel_accessibilite_path }
    it_behaves_like "an accessible page"
  end

  describe "Déclaration d’accessibilité" do
    let(:path) { declaration_accessibilite_path }
    it_behaves_like "an accessible page"
  end

  describe "Fiches conseil" do
    let(:path) { fiches_path }
    it_behaves_like "an accessible page"
  end

  Fiche.find_each do |fiche|
    describe "Fiche conseil #{fiche.title}" do
      let(:path) { fiche_path(fiche.id) }
      it_behaves_like "an accessible page"
    end
  end

  describe "Documentation conservateur" do
    let(:path) { content_blob_path(:documentation_conservateur) }
    it_behaves_like "an accessible page", :iframe
  end

  describe "Documentation commune" do
    let(:path) { content_blob_path(:aide_en_ligne) }
    it_behaves_like "an accessible page", :iframe
  end

  describe "Page d’accueil conservateurs" do
    let(:path) { accueil_conservateurs_path }
    it_behaves_like "an accessible page", :iframe
  end
end
