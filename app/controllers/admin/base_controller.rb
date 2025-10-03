# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :restrict_access
    before_action :require_two_factor_authentication
    before_action :disconnect_impersonating_user
    before_action :disconnect_impersonating_conservateur

    protected

    def restrict_access
      return true if current_admin_user.present?

      redirect_to new_admin_user_session_path, alert: "Vous n'êtes pas connecté en tant qu'admin"
    end

    def require_two_factor_authentication
      return if current_admin_user.blank?
      return if current_admin_user.otp_required_for_login?

      redirect_to admin_admin_user_two_factor_settings_path(current_admin_user),
                  alert: "Vous devez activer l'authentification à deux facteurs"
    end

    def disconnect_impersonating_user
      commune = current_user&.commune
      return if current_user.blank?

      session.delete(:user_impersonate_write)
      stop_impersonating_user
      redirect_to admin_commune_path(commune), notice: "Vous n’incarnez plus d’usager"
    end

    def disconnect_impersonating_conservateur
      return if current_conservateur.blank?

      session.delete(:conservateur_impersonate_write)
      stop_impersonating_conservateur
      redirect_to admin_conservateurs_path, notice: "Vous n’incarnez plus de conservateur"
    end
  end
end
