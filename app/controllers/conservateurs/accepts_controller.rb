# frozen_string_literal: true

module Conservateurs
  class AcceptsController < BaseController
    before_action :set_dossier, :set_dossier_accept

    def new; end

    def create
      # TODO : move this logic to DossierAccept model
      @dossier.update!(conservateur: current_conservateur) if @dossier.conservateur != current_conservateur
      if @dossier.accept!
        UserMailer.with(dossier: @dossier).dossier_accepted_email.deliver_now
        redirect_to conservateurs_commune_path(@dossier.commune), notice: "Le rapport a été envoyé à la commune"
      else
        render "conservateurs/accepts/new", status: :unprocessable_entity
      end
    end

    def update
      @dossier.update(**dossier_params)
      render partial: "form", locals: { dossier: @dossier }
    end

    protected

    def set_dossier
      @dossier = Dossier.find(params[:dossier_id])
    end

    def set_dossier_accept
      @dossier_accept = DossierAccept.new(dossier: @dossier)
      authorize(@dossier_accept)
    end

    def redirect_with_alert(alert)
      redirect_to conservateurs_commune_path(@dossier.commune), alert:
    end

    def dossier_params
      params
        .require(:dossier)
        .permit(:notes_conservateur)
        .merge(conservateur_id: current_conservateur.id)
    end
  end
end
