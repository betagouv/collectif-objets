# frozen_string_literal: true

module Conservateurs
  class RecenseurAccessesController < BaseController
    include NotifyRecenseurOfAccessChange

    before_action :set_recenseur

    # GET /conservateurs/recenseurs/1/accesses/new
    def new
      @communes = Commune.none
      @offset = Integer(params[:offset] || 0)
      @limit = 10 # Pagination basique : si on récupère plus de 20 résultats, on affiche un lien pour charger la suite
      if params[:nom]
        @communes = policy_scope(Commune).includes(:departement).offset(@offset).limit(@limit + 1)
                           .ransack(nom_unaccented_cont: params[:nom], s: "departement_code asc, nom asc").result
      end
      render "shared/recenseur_accesses/new"
    end

    # POST /conservateurs/recenseurs/1/accesses
    def create
      @access = @recenseur.accesses.build(commune_id: params[:commune_id], granted: true)
      authorize(@access)
      if @access.save
        @commune = @access.commune
        @recenseur.accesses.reload
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
        notice = @access.granted? ? "Accès accordé." : "Accès révoqué."

        respond_to do |format|
          format.turbo_stream { render "shared/recenseur_accesses/update" }
          format.html { redirect_to [namespace, @recenseur], notice:, status: :see_other }
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
