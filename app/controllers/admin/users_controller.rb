# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    skip_before_action :disconnect_impersonating_user, only: [:toggle_impersonate_mode]

    def new
      @user = User.new(commune_id: params[:commune_id])
    end

    def create
      @user = User.new(email: params[:user][:email], commune_id: params[:user][:commune_id], role: 'mairie', magic_token: SecureRandom.hex(10))
      if @user.save  
        redirect_to admin_commune_path(id: params[:user][:commune_id]), notice: "L'usager a été ajouté"
      else
        render :new
      end
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      if @user.update(user_params)
        redirect_to admin_commune_path(@user.commune), notice: "L'usager a été modifié"
      else
        render :edit
      end
    end

    def impersonate
      @user = User.find(params[:user_id])
      impersonate_user(@user)
      redirect_to commune_objets_path(@user.commune)
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

    def user_params
      params.require(:user).permit(:email)
    end

    def active_nav_links = %w[Communes]
  end
end
