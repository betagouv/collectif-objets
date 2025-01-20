# frozen_string_literal: true

module Conservateurs
  class RecenseurAccessesController < BaseController
    include NotifyRecenseurOfAccessChange

    before_action :set_recenseur

    # POST /conservateurs/recenseurs/1/accesses
    def create
      @access = @recenseur.accesses.build(commune_id: params[:commune_id], granted: true)
      if @access.save
        @commune = @access.commune
        @accesses = @recenseur.accesses.sorted.includes(:commune, :departement)
          .where(commune_id: current_conservateur.commune_ids)
        respond_to do |format|
          format.turbo_stream { render "shared/recenseur_accesses/create" }
          format.html { redirect_to [namespace, @recenseur], notice: "Accès ajouté." }
        end
      else
        head :unprocessable_entity
      end
    end

    # PATCH/PUT /conservateurs/recenseurs/1/accesses/1
    def update
      @access = @recenseur.accesses.find(params[:id])
      if @access.update(granted: access_params[:granted])
        respond_to do |format|
          format.turbo_stream { render "shared/recenseur_accesses/update" }
          format.html { redirect_to [namespace, @recenseur], notice: "Accès modifié.", status: :see_other }
        end
      else
        head :unprocessable_entity
      end
    end

    private

    def access_params
      params.require(:recenseur_access).permit(:commune_id, :granted)
    end

    def set_recenseur
      @recenseur = Recenseur.find(params[:recenseur_id])
      authorize(@recenseur)
    end
  end
end
