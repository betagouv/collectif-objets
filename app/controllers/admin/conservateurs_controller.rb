# frozen_string_literal: true

module Admin
  class ConservateursController < BaseController
    skip_before_action :disconnect_impersonating_conservateur, only: [:toggle_impersonate_mode]

    def index
      @ransack = Conservateur.order(:last_name).includes(:departements).ransack(params[:q])
      @query_present = params[:q].present?
      @pagy, @conservateurs = pagy(@ransack.result, items: 20)
    end

    def new
      @conservateur = Conservateur.new
    end

    def edit
      @conservateur = Conservateur.find(params[:id])
    end

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
      @conservateur = Conservateur.find(params[:id])
      if @conservateur.update(conservateur_params)
        redirect_to edit_admin_conservateur_path(@conservateur), notice: "Conservateur modifié !"
      else
        render :edit, status: :unprocessable_content
      end
    end

    def impersonate
      @conservateur = Conservateur.find(params[:conservateur_id])
      impersonate_conservateur(@conservateur)
      redirect_to after_sign_in_path_for_conservateur(@conservateur)
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

    def active_nav_links = %w[Conservateurs]
  end
end
