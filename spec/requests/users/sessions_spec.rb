# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::SessionsController, type: :request do
  let!(:departement) { create(:departement, code: "26", nom: "Drôme") }
  let!(:commune) { create(:commune, nom: "Albon", code_insee: "26002", departement:) }
  let!(:user) { create(:user, email: "mairie-albon@test.fr", commune:) }

  describe "GET /users/session/new" do
    context "with valid email parameter" do
      it "displays the user email when email exists" do
        get new_user_session_path(email: "mairie-albon@test.fr")
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("mairie-albon@test.fr")
      end
    end

    context "with blank email parameter" do
      it "redirects to session code path" do
        get new_user_session_path
        expect(response).to redirect_to(new_user_session_code_path)
      end
    end

    context "with non-existent email" do
      it "redirects with alert" do
        get new_user_session_path(email: "nonexistent@test.fr")
        expect(response).to redirect_to(new_user_session_code_path)
        follow_redirect!
        expect(response.body).to include("Aucune commune associée")
      end
    end

    context "with nested hash parameters (injection attempt)" do
      it "safely handles MongoDB-style injection syntax" do
        # Simulate URL like ?email[$eq]=accueil@ville-amberieu.fr
        get new_user_session_path, params: { email: { "$eq" => "accueil@ville-amberieu.fr" } }
        expect(response).to redirect_to(new_user_session_code_path)
      end

      it "does not crash with other hash parameters" do
        get new_user_session_path, params: { email: { "nested" => "value" } }
        expect(response).to redirect_to(new_user_session_code_path)
      end
    end
  end

  describe "POST /users/session" do
    context "with valid email and code" do
      before do
        dossier = create(:dossier, commune:)
        create(:recensement, dossier:, status: :completed)
        @session_code = create(:session_code, record: user)
      end

      it "signs in the user" do
        post user_session_path, params: { email: "mairie-albon@test.fr", code: @session_code.code }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(commune_objets_path(commune))
      end
    end

    context "with nested hash parameters in email" do
      it "safely handles injection attempts" do
        post user_session_path, params: { email: { "$eq" => "mairie-albon@test.fr" }, code: "000000" }
        expect(response).to redirect_to(new_user_session_code_path)
      end
    end

    context "with invalid code" do
      before do
        @session_code = create(:session_code, record: user)
      end

      it "does not sign in user" do
        post user_session_path, params: { email: "mairie-albon@test.fr", code: "000000" }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
