# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin impersonation", type: :request do
  let(:admin_user) { create(:admin_user) }

  before(:each) { login_as(admin_user, scope: :admin_user) }

  describe "usager (commune)" do
    let(:commune) { create(:commune) }
    let(:user) { create(:user, commune:) }

    it "incarne l'usager en lecture seule par défaut" do
      post impersonate_admin_user_path(user)

      expect(response).to redirect_to(commune_objets_path(commune))
      expect(session[:impersonated_user_id]).to eq user.id
      expect(session[:user_impersonate_write]).to be_nil
    end

    it "passe en mode écriture puis revient en lecture seule" do
      post impersonate_admin_user_path(user)

      post toggle_impersonate_mode_admin_users_path
      expect(session[:user_impersonate_write]).to eq "1"

      post toggle_impersonate_mode_admin_users_path
      expect(session[:user_impersonate_write]).to be_nil
    end

    it "arrête l'incarnation et nettoie la session" do
      post impersonate_admin_user_path(user)
      post toggle_impersonate_mode_admin_users_path

      delete stop_impersonating_admin_user_path(user)

      expect(response).to redirect_to(admin_commune_path(commune))
      expect(session[:impersonated_user_id]).to be_nil
      expect(session[:user_impersonate_write]).to be_nil
    end
  end

  describe "conservateur" do
    let(:conservateur) { create(:conservateur) }

    it "incarne le conservateur en lecture seule par défaut" do
      post impersonate_admin_conservateur_path(conservateur)

      expect(response).to redirect_to(conservateurs_departements_path)
      expect(session[:impersonated_conservateur_id]).to eq conservateur.id
      expect(session[:conservateur_impersonate_write]).to be_nil
    end

    it "passe en mode écriture puis revient en lecture seule" do
      post impersonate_admin_conservateur_path(conservateur)

      post toggle_impersonate_mode_admin_conservateurs_path
      expect(session[:conservateur_impersonate_write]).to eq "1"

      post toggle_impersonate_mode_admin_conservateurs_path
      expect(session[:conservateur_impersonate_write]).to be_nil
    end

    it "arrête l'incarnation et nettoie la session" do
      post impersonate_admin_conservateur_path(conservateur)
      post toggle_impersonate_mode_admin_conservateurs_path

      delete stop_impersonating_admin_conservateur_path(conservateur)

      expect(response).to redirect_to(admin_conservateurs_path)
      expect(session[:impersonated_conservateur_id]).to be_nil
      expect(session[:conservateur_impersonate_write]).to be_nil
    end
  end
end
