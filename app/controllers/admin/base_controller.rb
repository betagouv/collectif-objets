# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :restrict_access
    before_action :disconnect_impersonating_user
    before_action :disconnect_impersonating_conservateur

    layout "admin"

    protected

    def restrict_access
      return true if current_admin_user.present?

      redirect_to root_path, alert: "Vous n'êtes pas connecté en tant qu'admin"
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
