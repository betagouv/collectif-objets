# frozen_string_literal: true

module Admin
  class RecenseurAccessesController < BaseController
    include NotifyRecenseurOfAccessChange

    before_action :set_recenseur

    # GET /admin/recenseurs/1/accesses/new
    def new
      @communes = Commune.none
      @pagy = nil
      if params[:nom]
        communes_query = Commune.includes(:departement)
                                .ransack(nom_unaccented_cont: params[:nom], s: "departement_code asc, nom asc").result
        @pagy, @communes = pagy(communes_query, items: 10)
      end
      render "shared/recenseur_accesses/new"
    end

    # POST /admin/recenseurs/1/accesses
    def create
      @access = @recenseur.accesses.build(commune_id: params[:commune_id], granted: true)
      if @access.save
        @commune = @access.commune
        @accesses = @recenseur.accesses.sorted.includes(:commune, :departement)
        respond_to do |format|
          format.turbo_stream { render "shared/recenseur_accesses/create" }
          format.html { redirect_to [namespace, @recenseur], notice: "Accès ajouté." }
        end
      else
        head :unprocessable_entity
      end
    end

    # PATCH/PUT /admin/recenseurs/1/accesses/1
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
    end
  end
end
