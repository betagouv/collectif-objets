# frozen_string_literal: true

module Conservateurs
  class BordereauxController < BaseController
    before_action :set_commune, :set_dossier
    skip_after_action :verify_policy_scoped, only: :index

    def index
      @edifices = @commune.edifices.with_objets_classés_ou_inscrits.ordered_by_nom.includes(bordereau_attachment: :blob)
    end

    def create
      @edifice = Edifice.find(params[:edifice])
      raise unless @edifice.commune == @dossier.commune

      @edifice.bordereau&.purge

      GenerateBordereauPdfJob.perform_later(@dossier.id, @edifice.id)
      @edifice.update!(bordereau_generation_enqueued_at: Time.zone.now)

      respond_to do |format|
        format.html do
          redirect_to conservateurs_commune_bordereaux_path(@commune),
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
      authorize(@commune, :show?)
    end

    def active_nav_links = ["Mes départements", @commune.departement.to_s]
  end
end
