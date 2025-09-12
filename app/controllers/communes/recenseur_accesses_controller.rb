# frozen_string_literal: true

module Communes
  class RecenseurAccessesController < BaseController
    include NotifyRecenseurOfAccessChange

    before_action :set_access
    skip_after_action :verify_authorized # Objects are accessed through authorized relations only

    # PATCH/PUT /communes/1/recenseurs/1/accesses/1
    def update
      if @access.update(access_params)
        redirect_to [@commune, @recenseur], status: :see_other
      else
        head :unprocessable_entity
      end
    end

    # DELETE /communes/recenseurs/1
    def destroy
      @access.destroy!
      @access.recenseur.destroy if @recenseur.accesses.none?
      redirect_to commune_recenseurs_url, notice: "Accès supprimé.", status: :see_other
    end

    private

    def access_params
      params.require(:recenseur_access).permit(:all_edifices, edifice_ids: [])
    end

    def set_access
      @recenseur = @commune.recenseurs.find(params[:recenseur_id])
      @access = @recenseur.access_for(@commune)
    end
  end
end
