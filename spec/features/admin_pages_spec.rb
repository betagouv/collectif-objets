# frozen_string_literal: true

require "rails_helper"

feature "Admin", js: true do
  let!(:admin) { create(:admin_user, otp_required_for_login: true) }
  shared_examples "an accessible page" do |excludes|
    it "should be accessible" do
      login_as admin, scope: :admin_user
      visit path
      expect(current_path).to eql(path)
      expect(page.title).not_to eq("Collectif Objets") # Le titre par défaut
      expect(page).to be_axe_clean.excluding(*excludes)
    end
  end

  describe "Page d'accueil" do
    let(:path) { admin_path }
    it_behaves_like "an accessible page"
  end

  describe "communes" do
    let(:path) { admin_communes_path }
    it_behaves_like "an accessible page"
  end

  describe "commune" do
    let(:commune) { create(:commune) }
    let(:path) { admin_commune_path(commune) }
    it_behaves_like "an accessible page"
  end

  describe "conservateurs" do
    let(:path) { admin_conservateurs_path }
    it_behaves_like "an accessible page"
  end

  describe "conservateur/new" do
    let(:path) { new_admin_conservateur_path }
    it_behaves_like "an accessible page"
  end

  describe "admin_users" do
    let(:path) { admin_admin_users_path }
    it_behaves_like "an accessible page"
  end

  describe "admin_users/new" do
    let(:path) { new_admin_admin_user_path }
    it_behaves_like "an accessible page"
  end

  describe "admin_users/1" do
    let(:path) { admin_admin_user_path(admin) }
    it_behaves_like "an accessible page"
  end

  describe "campaigns" do
    let(:path) { admin_campaigns_path }
    it_behaves_like "an accessible page"
  end

  describe "campaigns/new" do
    let(:path) { new_admin_campaign_path }
    it_behaves_like "an accessible page"
  end

  describe "campaign" do
    let(:campaign) { create(:campaign) }
    let(:path) { admin_campaign_path(campaign) }
    it_behaves_like "an accessible page"
  end

  describe "campaign/mail_previews" do
    let(:campaign) { create(:campaign) }
    let!(:recipient) { create(:recipient, campaign:) }
    let(:path) { admin_campaign_mail_previews_path(campaign) }
    it_behaves_like "an accessible page", :iframe
  end

  describe "dossier" do
    let(:dossier) { create(:dossier, :accepted) }
    let(:path) { admin_dossier_path(dossier) }
    it_behaves_like "an accessible page"
  end

  describe "prévisualisation des mails" do
    let(:path) { admin_mail_previews_path }
    it_behaves_like "an accessible page"
  end

  describe "codes de connexion" do
    let(:path) { admin_session_codes_path }
    it_behaves_like "an accessible page"
  end

  describe "Exports pour mémoire" do
    let(:path) { admin_exports_memoire_index_path }
    it_behaves_like "an accessible page"
  end

  describe "Exports des objets déplacés" do
    let(:path) { admin_exports_deplaces_path }
    it_behaves_like "an accessible page"
  end

  describe "Exports des objets manquants" do
    let(:path) { admin_exports_manquants_path }
    it_behaves_like "an accessible page"
  end
end
