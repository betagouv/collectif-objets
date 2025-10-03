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

  context "2FA (two-factor authentication)" do
    context "GET admin/admin_users/:id/2fa" do
      let(:admin_with_secret) { create(:admin_user, otp_required_for_login: false, otp_secret: nil) }

      before { login_as(admin_with_secret, scope: :admin_user) }

      it "shows QR code for own account" do
        get admin_admin_user_two_factor_settings_path(admin_with_secret)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("<svg")
        expect(admin_with_secret.reload.otp_secret).to be_present
      end

      it "prevents configuring 2FA for other accounts" do
        other_admin = create(:admin_user, otp_required_for_login: false)
        get admin_admin_user_two_factor_settings_path(other_admin)
        expect(response).to redirect_to(admin_admin_users_path)
        expect(flash[:alert]).to match(/ne pouvez configurer que votre propre 2FA/i)
      end
    end

    context "POST admin/admin_users/:id/2fa/confirm" do
      let(:admin_with_secret) { create(:admin_user, otp_required_for_login: false) }

      before do
        admin_with_secret.otp_secret = AdminUser.generate_otp_secret
        admin_with_secret.save!
        login_as(admin_with_secret, scope: :admin_user)
      end

      it "enables 2FA with valid OTP and password and generates backup codes" do
        otp_code = admin_with_secret.current_otp
        post confirm_admin_admin_user_two_factor_settings_path(admin_with_secret),
             params: { otp_attempt: otp_code, password: admin_with_secret.password }

        expect(response).to redirect_to(backup_codes_admin_admin_user_two_factor_settings_path(admin_with_secret))
        expect(admin_with_secret.reload.otp_required_for_login).to be true
        expect(admin_with_secret.otp_backup_codes.count).to eq(10)
        follow_redirect!
        expect(response.body).to match(/2FA activé avec succès/i)
      end

      it "fails with invalid OTP code" do
        post confirm_admin_admin_user_two_factor_settings_path(admin_with_secret),
             params: { otp_attempt: "000000", password: admin_with_secret.password }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(admin_with_secret.reload.otp_required_for_login).to be false
        expect(response.body).to match(/Code invalide/i)
      end

      it "fails with invalid password" do
        otp_code = admin_with_secret.current_otp
        post confirm_admin_admin_user_two_factor_settings_path(admin_with_secret),
             params: { otp_attempt: otp_code, password: "wrongpassword" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(admin_with_secret.reload.otp_required_for_login).to be false
        expect(response.body).to match(/Mot de passe invalide/i)
      end
    end

    context "POST admin/admin_users/:id/2fa/disable" do
      let(:admin_with_2fa) { create(:admin_user, otp_required_for_login: true) }

      before do
        admin_with_2fa.otp_secret = AdminUser.generate_otp_secret
        admin_with_2fa.save!
        login_as(admin_with_2fa, scope: :admin_user)
      end

      it "disables 2FA with valid OTP and password" do
        otp_code = admin_with_2fa.current_otp
        post disable_admin_admin_user_two_factor_settings_path(admin_with_2fa),
             params: { otp_attempt: otp_code, password: admin_with_2fa.password }

        expect(response).to redirect_to(admin_admin_user_two_factor_settings_path(admin_with_2fa))
        admin_with_2fa.reload
        expect(admin_with_2fa.otp_required_for_login).to be false
        expect(admin_with_2fa.otp_secret).to be_nil
        follow_redirect!
        expect(response.body).to match(/2FA désactivé/i)
      end

      it "fails with invalid OTP code" do
        post disable_admin_admin_user_two_factor_settings_path(admin_with_2fa),
             params: { otp_attempt: "000000", password: admin_with_2fa.password }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(admin_with_2fa.reload.otp_required_for_login).to be true
        expect(response.body).to match(/Code 2FA invalide/i)
      end

      it "fails with invalid password" do
        otp_code = admin_with_2fa.current_otp
        post disable_admin_admin_user_two_factor_settings_path(admin_with_2fa),
             params: { otp_attempt: otp_code, password: "wrongpassword" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(admin_with_2fa.reload.otp_required_for_login).to be true
        expect(response.body).to match(/Mot de passe invalide/i)
      end

      it "clears backup codes when disabling 2FA" do
        otp_code = admin_with_2fa.current_otp
        admin_with_2fa.generate_otp_backup_codes!
        expect(admin_with_2fa.otp_backup_codes).not_to be_empty

        post disable_admin_admin_user_two_factor_settings_path(admin_with_2fa),
             params: { otp_attempt: otp_code, password: admin_with_2fa.password }

        expect(admin_with_2fa.reload.otp_backup_codes).to be_empty
      end
    end

    context "Backup codes" do
      let(:admin_with_backup_codes) { create(:admin_user) }

      before do
        admin_with_backup_codes.otp_secret = AdminUser.generate_otp_secret
        admin_with_backup_codes.save!
      end

      it "generates 10 backup codes" do
        codes = admin_with_backup_codes.generate_otp_backup_codes!
        expect(codes.length).to eq(10)
        expect(codes.first).to match(/\A[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}\z/)
      end

      it "validates and consumes a backup code" do
        codes = admin_with_backup_codes.generate_otp_backup_codes!
        code_to_use = codes.first

        expect(admin_with_backup_codes.invalidate_otp_backup_code!(code_to_use)).to be true
        expect(admin_with_backup_codes.invalidate_otp_backup_code!(code_to_use)).to be false
      end

      it "tracks when codes are used" do
        codes = admin_with_backup_codes.generate_otp_backup_codes!
        admin_with_backup_codes.invalidate_otp_backup_code!(codes.first)

        used_code = admin_with_backup_codes.otp_backup_codes.first
        expect(used_code["used_at"]).to be_present
      end

      it "normalizes backup codes (removes dashes)" do
        codes = admin_with_backup_codes.generate_otp_backup_codes!
        code_with_dashes = codes.first
        code_without_dashes = code_with_dashes.gsub("-", "")

        expect(admin_with_backup_codes.invalidate_otp_backup_code!(code_without_dashes)).to be true
      end

      it "counts remaining backup codes" do
        codes = admin_with_backup_codes.generate_otp_backup_codes!
        expect(admin_with_backup_codes.otp_backup_codes_remaining).to eq(10)

        admin_with_backup_codes.invalidate_otp_backup_code!(codes.first)
        expect(admin_with_backup_codes.otp_backup_codes_remaining).to eq(9)
      end
    end
  end
end
