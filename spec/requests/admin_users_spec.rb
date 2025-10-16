# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::AdminUsersController, type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:params) { {} }

  subject(:perform_request) { send(method, path, params:) }

  context "when logged in as admin" do
    before(:each) { login_as(admin_user, scope: :admin_user) }

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

      it "supprime l'admin" do
        expect { perform_request }.to change(AdminUser, :count).by(-1)
      end
    end
  end

  context "2FA (two-factor authentication)" do
    context "GET /admin/admin_users/2fa" do
      let(:admin_without_2fa) { create(:admin_user, otp_required_for_login: false) }

      before { login_as(admin_without_2fa, scope: :admin_user) }

      it "shows 2FA setup page" do
        get admin_two_factor_settings_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Authentification à deux facteurs")
      end
    end

    context "POST /admin/admin_users/2fa/enable" do
      let(:admin_with_secret) { create(:admin_user, otp_required_for_login: false) }

      before do
        admin_with_secret.otp_secret = AdminUser.generate_otp_secret
        admin_with_secret.save!
        login_as(admin_with_secret, scope: :admin_user)
      end

      it "enables 2FA with valid OTP and password and generates backup codes" do
        otp_code = admin_with_secret.current_otp
        post enable_admin_two_factor_settings_path,
             params: { otp_attempt: otp_code, password: admin_with_secret.password }

        expect(response).to redirect_to(backup_codes_admin_two_factor_settings_path)
        expect(flash[:notice]).to match(/authentification à deux facteurs activée/i)
        expect(admin_with_secret.reload.otp_required_for_login).to be true
        expect(admin_with_secret.otp_backup_codes.size).to eq(10)
      end

      it "fails with invalid OTP code" do
        post enable_admin_two_factor_settings_path,
             params: { otp_attempt: "000000", password: admin_with_secret.password }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(admin_with_secret.reload.otp_required_for_login).to be false
        expect(response.body).to match(/Code ou mot de passe invalide/i)
      end

      it "fails with invalid password" do
        otp_code = admin_with_secret.current_otp
        post enable_admin_two_factor_settings_path,
             params: { otp_attempt: otp_code, password: "wrongpassword" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(admin_with_secret.reload.otp_required_for_login).to be false
        expect(response.body).to match(/Code ou mot de passe invalide/i)
      end
    end

    context "POST /admin/admin_users/2fa/disable" do
      let(:admin_with_2fa) { create(:admin_user, otp_required_for_login: true) }

      before do
        admin_with_2fa.otp_secret = AdminUser.generate_otp_secret
        admin_with_2fa.save!
        login_as(admin_with_2fa, scope: :admin_user)
      end

      it "disables 2FA with valid OTP and password" do
        otp_code = admin_with_2fa.current_otp
        post disable_admin_two_factor_settings_path,
             params: { otp_attempt: otp_code, password: admin_with_2fa.password }

        expect(response).to redirect_to(admin_two_factor_settings_path)
        expect(flash[:notice]).to match(/authentification à deux facteurs désactivée/i)
        admin_with_2fa.reload
        expect(admin_with_2fa.otp_required_for_login).to be false
        expect(admin_with_2fa.otp_secret).to be_nil
      end

      it "fails with invalid OTP code" do
        post disable_admin_two_factor_settings_path,
             params: { otp_attempt: "000000", password: admin_with_2fa.password }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(admin_with_2fa.reload.otp_required_for_login).to be true
        expect(response.body).to match(/Code ou mot de passe invalide/i)
      end

      it "fails with invalid password" do
        otp_code = admin_with_2fa.current_otp
        post disable_admin_two_factor_settings_path,
             params: { otp_attempt: otp_code, password: "wrongpassword" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(admin_with_2fa.reload.otp_required_for_login).to be true
        expect(response.body).to match(/Code ou mot de passe invalide/i)
      end

      it "clears backup codes when disabling 2FA" do
        otp_code = admin_with_2fa.current_otp
        admin_with_2fa.generate_otp_backup_codes!
        expect(admin_with_2fa.otp_backup_codes).not_to be_empty

        post disable_admin_two_factor_settings_path,
             params: { otp_attempt: otp_code, password: admin_with_2fa.password }

        expect(admin_with_2fa.reload.otp_backup_codes).to be_nil
      end
    end

    context "GET /admin/admin_users/2fa/backup_codes" do
      let(:admin_without_2fa) { create(:admin_user, otp_required_for_login: false) }

      before do
        admin_without_2fa.otp_secret = AdminUser.generate_otp_secret
        admin_without_2fa.save!
        login_as(admin_without_2fa, scope: :admin_user)
      end

      it "shows backup codes after successful 2FA enablement" do
        otp_code = admin_without_2fa.current_otp
        post enable_admin_two_factor_settings_path,
             params: { otp_attempt: otp_code, password: admin_without_2fa.password }

        follow_redirect!
        expect(response).to have_http_status(:success)
        expect(response.body).to include("codes de secours")
      end

      it "redirects to show page if no backup codes in session" do
        get backup_codes_admin_two_factor_settings_path

        expect(response).to redirect_to(admin_two_factor_settings_path)
      end
    end

    context "POST /admin/admin_users/2fa/regenerate_backup_codes" do
      let(:admin_with_2fa) { create(:admin_user, otp_required_for_login: true) }

      before do
        admin_with_2fa.otp_secret = AdminUser.generate_otp_secret
        admin_with_2fa.save!
        login_as(admin_with_2fa, scope: :admin_user)
      end

      it "regenerates backup codes with valid OTP and password" do
        old_codes = admin_with_2fa.generate_otp_backup_codes!
        admin_with_2fa.save!
        admin_with_2fa.reload

        otp_code = admin_with_2fa.current_otp
        post regenerate_backup_codes_admin_two_factor_settings_path,
             params: { otp_attempt: otp_code, password: admin_with_2fa.password }

        expect(response).to redirect_to(backup_codes_admin_two_factor_settings_path)
        expect(flash[:notice]).to match(/nouveaux codes de secours générés/i)
        expect(admin_with_2fa.reload.otp_backup_codes).not_to eq(old_codes)
        expect(admin_with_2fa.otp_backup_codes.size).to eq(10)
      end

      it "fails with invalid OTP code" do
        post regenerate_backup_codes_admin_two_factor_settings_path,
             params: { otp_attempt: "000000", password: admin_with_2fa.password }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match(/Code ou mot de passe invalide/i)
      end

      it "fails with invalid password" do
        otp_code = admin_with_2fa.current_otp
        post regenerate_backup_codes_admin_two_factor_settings_path,
             params: { otp_attempt: otp_code, password: "wrongpassword" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match(/Code ou mot de passe invalide/i)
      end

      it "works even after using all backup codes" do
        admin_with_2fa.update!(otp_backup_codes: [])
        expect(admin_with_2fa.remaining_otp_backup_codes).to eq 0

        otp_code = admin_with_2fa.current_otp
        post regenerate_backup_codes_admin_two_factor_settings_path,
             params: { otp_attempt: otp_code, password: admin_with_2fa.password }

        expect(response).to redirect_to(backup_codes_admin_two_factor_settings_path)
        expect(admin_with_2fa.reload.otp_backup_codes.size).to eq(10)
      end
    end
  end
end
