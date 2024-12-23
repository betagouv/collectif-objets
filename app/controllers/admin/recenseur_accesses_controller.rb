# frozen_string_literal: true

module Admin
  class RecenseurAccessesController < BaseController
    before_action :set_recenseur

    # POST /admin/recenseurs/1/accesses
    def create
      @access = @recenseur.accesses.build(commune_id: params[:commune_id], granted: true)
      if @access.save
        @commune = @access.commune
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to [:admin, @recenseur], notice: "Accès ajouté." }
        end
      else
        head :unprocessable_entity
      end
    end

    # PATCH/PUT /admin/recenseurs/1/accesses/1
    def update
      @access = @recenseur.accesses.find(params[:id])
      if @access.update(granted: access_params[:granted])
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to [:admin, @recenseur], notice: "Accès modifié.", status: :see_other }
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
    end
  end
end
