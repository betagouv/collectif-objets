# frozen_string_literal: true

module Conservateurs
  class BordereauxController < BaseController
    before_action :set_commune, :set_dossier
    before_action :set_bordereau, only: [:create, :show]
    skip_after_action :verify_policy_scoped, only: :index

    def index
      @bordereaux = Bordereau.for(@commune) if @dossier
    end

    def show
      @bordereau.generate_pdf unless @bordereau.generated?
      redirect_to rails_blob_path(@bordereau.file, disposition: "attachment")
    end

    def create
      @bordereau.persist(bordereau_params)
      @bordereau.generate_pdf
    end

    protected

    def set_dossier
      @dossier = @commune.dossier
      authorize(@dossier, :show?) if @dossier
    end

    def set_commune
      @commune = Commune.find(params[:commune_id])
      authorize(@commune, :show?)
    end

    def set_bordereau
      if (id = params[:id].presence)
        @bordereau = @dossier.bordereaux.find(id)
      else
        edifice_id = params[:edifice_id]
        @bordereau = @dossier.bordereaux.find_or_initialize_by(dossier: @dossier, edifice_id:)
      end
    end

    def bordereau_params
      return {} unless params[:bordereau]

      params.require(:bordereau).permit(
        bordereau_recensements_attributes: [
          :recensement_id, :etat_sanitaire,
          :notes_commune, :notes_conservateur, :notes_affectataire, :notes_proprietaire
        ]
      )
    end

    def active_nav_links = ["Mes départements", @commune.departement.to_s]
  end
end
