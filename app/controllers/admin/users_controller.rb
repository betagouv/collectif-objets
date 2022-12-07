# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :set_user

    def impersonate
      impersonate_user(@user)
      redirect_to commune_objets_path(@user.commune), notice: "Vous incarnez maintenant l'usager #{@user}"
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end
  end
end
