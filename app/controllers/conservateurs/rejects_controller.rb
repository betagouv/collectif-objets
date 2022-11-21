# frozen_string_literal: true

module Conservateurs
  class RejectsController < BaseController
    before_action :set_dossier, :set_dossier_reject, :set_commune

    def new; end

    def create
      if @dossier.reject!
        UserMailer.with(dossier: @dossier).dossier_rejected_email.deliver_later
        redirect_to conservateurs_commune_path(@commune, warning: "Le dossier a été renvoyé à la commune")
      else
        render "conservateurs/rejects/new", status: :unprocessable_entity
      end
    end

    def update
      @dossier.update(**dossier_params.to_h)
      if @dossier.notes_conservateur.blank?
        @dossier.errors.add(
          :notes_conservateur,
          "Vous devez renseigner des retours pour la commune"
        )
      end
      render partial: "form", locals: { dossier: @dossier }
    end

    protected

    def set_dossier
      @dossier = Dossier.find(params[:dossier_id])
    end

    def set_commune
      @commune = @dossier.commune
    end

    def set_dossier_reject
      @dossier_reject = DossierReject.new(dossier: @dossier)
      authorize(@dossier_reject)
    end

    def redirect_with_alert(alert)
      redirect_to conservateurs_commune_path(@commune), alert:
    end

    def dossier_params
      params
        .require(:dossier)
        .permit(:notes_conservateur)
        .merge(conservateur_id: current_conservateur.id)
    end
  end
end
