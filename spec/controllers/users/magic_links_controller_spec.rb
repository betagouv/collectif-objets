# frozen_string_literal: true

require "rails_helper"

describe Users::MagicLinksController, type: :controller do
  describe "#create" do
    let(:user) { create(:user) }

    subject { post :create, params: { user: { email: } } }

    context "user exists" do
      let(:email) { user.email }

      it "sets flash success message" do
        subject
        expect(flash[:notice]).to eq("Un lien de connexion valide 24 heures vous a été envoyé")
      end

      it "redirects user with success" do
        subject
        expect(response).to redirect_to(new_user_session_path(user: { email: }, success: true))
      end
    end

    context "user not found" do
      let(:email) { "random_email@example.fr" }

      it "sets flash error message" do
        subject
        expect(flash[:alert]).to eq("Aucun compte n'a été trouvé pour l'email #{email}")
      end

      it "redirects user with error" do
        subject
        expect(response).to redirect_to(new_user_session_path(user: { email: }, error: true))
      end
    end

    context "email is missing" do
      let(:email) { "" }

      it "redirects user with alert" do
        subject
        expect(response).to redirect_to(new_user_session_path(alert: "Veuillez renseigner votre email"))
      end
    end
  end
end
