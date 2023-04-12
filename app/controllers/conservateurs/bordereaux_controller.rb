# frozen_string_literal: true

module Conservateurs
  class BordereauxController < BaseController
    before_action :set_commune, :set_dossier

    def new; end

    def create
      @edifice = Edifice.find(params[:edifice_id])
      raise unless @edifice.commune == @dossier.commune

      @edifice.bordereau&.purge

      GenerateBordereauPdfJob.perform_async(@dossier.id, @edifice.id)
      @edifice.update!(bordereau_generation_enqueued_at: Time.zone.now)

      respond_to do |format|
        format.html do
          redirect_to new_conservateurs_commune_bordereau_path(@commune),
                      notice: "Le bordereau est en cours de génération …"
        end
        format.turbo_stream
      end
    end

    protected

    def set_dossier
      @dossier = @commune.dossier
      authorize(@dossier, :show?) if @dossier
    end

    def set_commune
      @commune = Commune.find(params[:commune_id])
    end

    def active_nav_links = ["Mes départements", @dossier.departement.to_s]
  end
end
