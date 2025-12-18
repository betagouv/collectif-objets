# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:impersonate, :stop_impersonating]
    skip_before_action :disconnect_impersonating_user, only: [:toggle_impersonate_mode, :stop_impersonating]

    def impersonate
      impersonate_user(@user)
      redirect_to commune_objets_path(@user.commune)
    end

    def stop_impersonating
      commune = current_user&.commune
      session.delete(:user_impersonate_write)
      stop_impersonating_user
      redirect_to admin_commune_path(commune), notice: "Vous n'incarnez plus d'usager"
    end

    def toggle_impersonate_mode
      if session[:user_impersonate_write].present?
        session.delete(:user_impersonate_write)
      else
        session[:user_impersonate_write] = "1"
      end
      redirect_back fallback_location: commune_objets_path(current_user.commune), status: :see_other
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def active_nav_links = %w[Communes]
  end
end
