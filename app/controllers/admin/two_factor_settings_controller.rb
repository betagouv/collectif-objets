# frozen_string_literal: true

module Admin
  class TwoFactorSettingsController < BaseController
    skip_before_action :require_two_factor_authentication
    before_action :set_admin_user
    before_action :ensure_own_account
    before_action :ensure_otp_secret, only: [:show, :confirm]
    before_action :set_qr_code, only: [:show, :confirm]
    before_action :require_password_confirmation, only: [:disable, :confirm]

    def show
      if @admin_user.otp_required_for_login?
        render :disable
      else
        render :enable
      end
    end

    def confirm
      if @admin_user.validate_and_consume_otp!(params[:otp_attempt])
        @admin_user.update!(otp_required_for_login: true)
        backup_codes = @admin_user.generate_otp_backup_codes!
        session[:backup_codes] = backup_codes
        redirect_to backup_codes_admin_admin_user_two_factor_settings_path(@admin_user),
                    notice: "Authentification 2FA activée avec succès"
      else
        flash.now[:alert] = "Code invalide"
        render :enable, status: :unprocessable_entity
      end
    end

    def backup_codes
      return if (@backup_codes = session.delete(:backup_codes))

      redirect_to admin_admin_user_two_factor_settings_path(@admin_user)
    end

    def disable
      unless @admin_user.validate_and_consume_otp!(params[:otp_attempt])
        flash.now[:alert] = "Code 2FA invalide"
        render :disable, status: :unprocessable_entity
        return
      end

      @admin_user.update!(otp_required_for_login: false, otp_secret: nil, otp_backup_codes: [])
      redirect_to admin_admin_user_two_factor_settings_path(@admin_user), notice: "Authentification 2FA désactivée"
    end

    private

    def set_admin_user
      @admin_user = AdminUser.find(params[:admin_user_id])
    end

    def ensure_own_account
      return if @admin_user == current_admin_user

      redirect_to admin_admin_users_path, alert: "Vous ne pouvez configurer que votre propre 2FA"
    end

    def ensure_otp_secret
      return if @admin_user.otp_secret.present?

      @admin_user.otp_secret = AdminUser.generate_otp_secret
      @admin_user.save!
    end

    def set_qr_code
      return if @admin_user.otp_required_for_login?

      @qr_code = generate_qr_code
    end

    def generate_qr_code
      require "rqrcode"
      env_suffix = if Rails.application.staging?
                     " (staging)"
                   elsif !Rails.env.production?
                     " (#{Rails.env})"
                   else
                     ""
                   end
      issuer = "Collectif Objets#{env_suffix}"
      label = "#{issuer}:#{@admin_user.email}"
      otp_uri = @admin_user.otp_provisioning_uri(label, issuer:)
      qr = RQRCode::QRCode.new(otp_uri)
      qr.as_svg(module_size: 4, color: "000", fill: "fff")
    end

    def require_password_confirmation
      return if params[:password].present? && current_admin_user.valid_password?(params[:password])

      flash.now[:alert] = "Mot de passe invalide"
      if action_name == "confirm"
        render :enable, status: :unprocessable_entity
      else
        render :disable, status: :unprocessable_entity
      end
    end
  end
end
