# frozen_string_literal: true

module Admin
  class ConservateursController < BaseController
    before_action :set_conservateur, only: [:edit, :update, :impersonate, :stop_impersonating]
    skip_before_action :disconnect_impersonating_conservateur, only: [:toggle_impersonate_mode, :stop_impersonating]

    def index
      @ransack = Conservateur.order(:last_name).includes(:departements).ransack(params[:q])
      @query_present = params[:q].present?
      @pagy, @conservateurs = pagy(@ransack.result, items: 20)
    end

    def new
      @conservateur = Conservateur.new
    end

    def edit; end

    def create
      @conservateur = Conservateur.new(conservateur_params)
      @conservateur.password = SecureRandom.hex(25)
      if @conservateur.save
        redirect_to edit_admin_conservateur_path(@conservateur), notice: "Conservateur créé !"
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @conservateur.update(conservateur_params)
        redirect_to edit_admin_conservateur_path(@conservateur), notice: "Conservateur modifié !"
      else
        render :edit, status: :unprocessable_content
      end
    end

    def impersonate
      impersonate_conservateur(@conservateur)
      redirect_to after_sign_in_path_for_conservateur(@conservateur)
    end

    def stop_impersonating
      session.delete(:conservateur_impersonate_write)
      stop_impersonating_conservateur
      redirect_to admin_conservateurs_path, notice: "Vous n'incarnez plus de conservateur"
    end

    def toggle_impersonate_mode
      if session[:conservateur_impersonate_write].present?
        session.delete(:conservateur_impersonate_write)
      else
        session[:conservateur_impersonate_write] = "1"
      end
      redirect_back fallback_location: conservateurs_departements_path, status: :see_other
    end

    private

    def conservateur_params
      params.require(:conservateur).permit(:email, :phone_number, :first_name, :last_name, departement_ids: [])
    end

    def set_conservateur
      @conservateur = Conservateur.find(params[:id])
    end

    def active_nav_links = %w[Conservateurs]
  end
end
