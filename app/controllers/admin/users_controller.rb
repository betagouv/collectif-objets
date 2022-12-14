# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def impersonate
      @user = User.find(params[:user_id])
      impersonate_user(@user)
      redirect_to commune_objets_path(@user.commune)
    end

    def stop_impersonating
      session.delete(:user_impersonate_write)
      stop_impersonating_user
      redirect_to "/", notice: "Vous n'incarnez plus d'usager", status: :see_other
    end

    def toggle_impersonate_mode
      if session[:user_impersonate_write].present?
        session.delete(:user_impersonate_write)
      else
        session[:user_impersonate_write] = "1"
      end
      redirect_back fallback_location: commune_objets_path(current_user.commune), status: :see_other
    end
  end
end
