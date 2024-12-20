# frozen_string_literal: true

module Admin
  class AdminUsersController < BaseController
    before_action :set_admin_user, only: [:show, :edit, :update, :destroy]

    def index
      @admin_users = AdminUser.order(:first_name, :last_name)
    end

    def show; end

    def new
      @admin_user = AdminUser.new
    end

    def edit; end

    def create
      @admin_user = AdminUser.new(admin_user_params)
      if @admin_user.save
        redirect_to [:admin, @admin_user], notice: "Administrateur créé !"
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @admin_user.update(admin_user_params)
        redirect_to [:admin, @admin_user], notice: "Administrateur modifié !"
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      if @admin_user.destroy
        redirect_to admin_admin_users_path, notice: "Administrateur supprimé !"
      else
        render :show, status: :unprocessable_content
      end
    end

    private

    def set_admin_user
      @admin_user = AdminUser.find(params[:id])
    end

    def admin_user_params
      authorized_params = [:email, :first_name, :last_name]
      authorized_params.push(:password) if action_name == "create"
      params.require(:admin_user).permit(*authorized_params)
    end

    def active_nav_links = %w[Administration Admins]
  end
end
