# frozen_string_literal: true

module Admin
  class TwoFactorSettingsController < BaseController
    skip_before_action :require_two_factor_authentication
    before_action :require_2fa_confirmation, only: [:enable, :disable, :regenerate_backup_codes]

    def show
      current_admin_user.find_or_generate_otp_secret
    end

    def enable
      session[:backup_codes] = current_admin_user.enable_2fa!
      redirect_to backup_codes_admin_two_factor_settings_path,
                  notice: "Authentification à deux facteurs activée avec succès"
    end

    def backup_codes
      @backup_codes = session.delete(:backup_codes)
      redirect_to admin_two_factor_settings_path if @backup_codes.nil?
    end

    def regenerate_backup_codes
      session[:backup_codes] = current_admin_user.generate_otp_backup_codes!
      current_admin_user.save!
      redirect_to backup_codes_admin_two_factor_settings_path,
                  notice: "Nouveaux codes de secours générés"
    end

    def disable
      current_admin_user.disable_2fa!
      redirect_to admin_two_factor_settings_path,
                  notice: "Authentification à deux facteurs désactivée"
    end

    private

    def require_2fa_confirmation
      return if current_admin_user.valid_password?(params[:password]) \
             && current_admin_user.validate_and_consume_otp!(params[:otp_attempt])

      flash.now[:alert] = "Code ou mot de passe invalide"
      render :show, status: :unprocessable_entity
    end

    def active_nav_links = %w[Administration]
  end
end
