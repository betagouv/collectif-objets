# frozen_string_literal: true

module Conservateurs
  class RapportsController < ApplicationController
    before_action :set_dossier, :set_commune, :restrict_access, :prevent_not_completed

    def update
      return unless @dossier.update(dossier_params)

      GenerateRapportPdfJob.perform_async(@dossier.id)
      sleep 1 if Rails.env.test? # avoids race condition on pdf purge
      return unless @dossier.pdf.attached?

      @dossier.pdf.purge
      BroadcastDossierRapportUpdateJob.perform_inline(@dossier.id)

      render partial: "form", locals: { dossier: @dossier }
    end

    protected

    def dossier_params
      params.require(:dossier).permit(:notes_conservateur)
    end

    def set_dossier
      @dossier = Dossier.find(params[:dossier_id])
    end

    def set_commune
      @commune = @dossier.commune
    end

    def restrict_access
      if current_conservateur.nil?
        redirect_to root_path, alert: "Veuillez vous connecter"
      elsif current_conservateur.departements.exclude?(@commune.departement)
        redirect_to root_path, alert: "Vous n'avez pas accès au département de cet objet"
      end
    end

    def prevent_not_completed
      return true if @commune.completed? && @dossier.recensements.not_analysed.empty?

      redirect_to conservateurs_commune_path(@commune), alert: I18n.t("recensement.analyse.not_completed")
    end
  end
end
