# frozen_string_literal: true

module Conservateurs
  class AcceptsController < BaseController
    before_action :set_dossier, :set_dossier_accept, :set_commune

    def new; end

    def create
      if @dossier.update(**dossier_params) && @dossier.accept!
        UserMailer.with(dossier: @dossier).dossier_accepted_email.deliver_now
        redirect_to conservateurs_commune_path(@commune), notice: "L'examen a été envoyé à la commune"
      else
        render "conservateurs/accepts/new", status: :unprocessable_content
      end
    end

    def update
      @dossier.update(**dossier_params)
      render partial: "form", locals: { dossier: @dossier, preview_expanded: params[:preview_expanded] }
    end

    # Pour ré ouvrir un dossier
    def destroy
      @dossier.reopen!
      redirect_to conservateurs_commune_path(@commune), notice: "Le dossier a été ré ouvert"
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
      @objets = @commune.objets.includes(:commune, recensements: %i[photos_attachments photos_blobs])
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
