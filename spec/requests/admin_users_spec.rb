# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::AdminUsersController, type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:params) { {} }

  before(:each) { login_as(admin_user, scope: :admin_user) }

  subject(:perform_request) { send(method, path, params:) }

  context "GET admin/admin_users" do
    let(:method) { :get }
    let(:path) { admin_admin_users_path }

    it "liste les admins" do
      perform_request
      expect(response.body).to match admin_user.to_s
    end
  end

  context "GET admin/admin_users/1" do
    let(:method) { :get }
    let(:path) { admin_admin_user_path(admin_user) }

    it "affiche l'admin" do
      perform_request
      expect(response.body).to match admin_user.to_s
    end
  end

  context "POST admin/admin_users" do
    let(:method) { :post }
    let(:path) { admin_admin_users_path }

    context "quand les paramètres sont valides" do
      let(:params) { { admin_user: attributes_for(:admin_user) } }
      it "crée un nouvel admin" do
        expect { perform_request }.to change(AdminUser, :count).by(1)
      end
    end

    context "quand les paramètres sont invalides" do
      let(:params) { { admin_user: attributes_for(:admin_user).except(:email) } }
      it "n'enregistre pas de nouvel admin" do
        expect { perform_request }.to change(AdminUser, :count).by(0)
      end
    end
  end

  context "PATCH admin/admin_users/1" do
    let(:method) { :patch }
    let(:path) { admin_admin_user_path(admin_user) }

    context "quand les paramètres sont valides" do
      let(:params) { { admin_user: attributes_for(:admin_user).except(:password) } }
      it "modifie l'admin" do
        expect do
          perform_request
          admin_user.reload
        end.to change(admin_user, :email).to(params[:admin_user][:email])
      end
    end

    context "quand les paramètres sont invalides" do
      let(:params) { { admin_user: attributes_for(:admin_user).except(:email) } }
      it "ne modifie pas l'admin" do
        expect { perform_request }.not_to change(admin_user, :email)
      end
    end
  end

  context "DELETE admin/admin_users/1" do
    let(:method) { :delete }
    let(:path) { admin_admin_user_path(admin_user) }

    it "supprime le recensement" do
      expect { perform_request }.to change(AdminUser, :count).by(-1)
    end
  end
end
