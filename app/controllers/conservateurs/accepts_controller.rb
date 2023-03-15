# frozen_string_literal: true

module Conservateurs
  class AcceptsController < BaseController
    before_action :set_dossier, :set_dossier_accept, :set_commune

    def new; end

    def create
      if @dossier.update(**dossier_params) && @dossier.accept!
        UserMailer.with(dossier: @dossier).dossier_accepted_email.deliver_now
        redirect_to conservateurs_commune_path(@commune), notice: "Le rapport a été envoyé à la commune"
      else
        render "conservateurs/accepts/new", status: :unprocessable_entity
      end
    end

    def update
      @dossier.update(**dossier_params)
      render partial: "form", locals: { dossier: @dossier, preview_expanded: params[:preview_expanded] }
    end

    protected

    def set_dossier
      @dossier = Dossier.find(params[:dossier_id])
    end

    def set_dossier_accept
      @dossier_accept = DossierAccept.new(dossier: @dossier)
      authorize(@dossier_accept)
    end

    def set_commune
      @commune = @dossier.commune
      @objets = @commune.objets.with_photos_first.includes(:commune, recensements: %i[photos_attachments photos_blobs])
    end

    def redirect_with_alert(alert)
      redirect_to conservateurs_commune_path(@commune), alert:
    end

    def dossier_params
      params
        .require(:dossier)
        .permit(:notes_conservateur, :visit)
        .merge(conservateur_id: current_conservateur.id)
        .transform_values { |v| v == "" ? nil : v }
    end

    def active_nav_links = ["Mes départements", @commune.departement.to_s]
  end
end
