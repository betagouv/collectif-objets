# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def impersonate
      @user = User.find(params[:user_id])
      impersonate_user(@user)
      redirect_to commune_objets_path(@user.commune)
    end

    def stop_impersonating
      stop_impersonating_user
      redirect_to admin_path, notice: "Vous n'incarnez plus d'usager"
    end
  end
end
