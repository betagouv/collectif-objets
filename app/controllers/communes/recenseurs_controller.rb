# frozen_string_literal: true

module Communes
  class RecenseursController < BaseController
    include NotifyRecenseurOfAccessChange

    skip_after_action :verify_authorized, only: [:create, :destroy]

    # GET /communes/1/recenseurs
    def index
      @recenseurs = policy_scope(Recenseur).order(created_at: :desc)
    end

    # POST /communes/recenseurs
    def create
      @recenseur = Recenseur.find_or_initialize_by(email: recenseur_params[:email])
      @recenseur.nom = recenseur_params[:nom] if recenseur_params[:nom].present?
      if recenseur_params[:notes].present?
        @recenseur.append_to_notes "Notes de #{@commune.nom} : #{recenseur_params[:notes]}"
      end
      @recenseur.accesses.find_or_initialize_by(commune: @commune)

      if @recenseur.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to commune_recenseurs_path, notice: "Recenseur créé avec succès." }
        end
      else
        respond_to do |format|
          format.turbo_stream { render "communes/recenseurs/form", recenseur: @recenseur }
          format.html { render :index, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /communes/recenseurs/1
    def destroy
      @recenseur = @commune.recenseurs.find(params[:id])
      @recenseur.accesses.find_by(commune: @commune).destroy!
      @recenseur.destroy if @recenseur.accesses.none?
      redirect_to commune_recenseurs_url, notice: "Accès supprimé.", status: :see_other
    end

    private

    def recenseur_params
      params.require(:recenseur).permit(:email, :nom, :notes)
    end

    def active_nav_links = ["Recenseurs"]
  end
end
