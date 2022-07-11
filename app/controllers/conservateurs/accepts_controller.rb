# frozen_string_literal: true

module Conservateurs
  class AcceptsController < ApplicationController
    before_action :set_dossier, :set_commune, :restrict_access, :restrict_commune_completed,
                  :restrict_dossier_submitted, :prevent_pending_recensements

    def new; end

    def update
      @dossier.update(**dossier_params)
      render partial: "form", locals: { dossier: @dossier }
    end

    def create
      if @dossier.accept!
        UserMailer.with(dossier: @dossier).dossier_accepted_email.deliver_now
        redirect_to conservateurs_commune_path(@commune), notice: "Le rapport a été envoyé à la commune"
      else
        render "conservateurs/analyses/new", status: :unprocessable_entity
      end
    end

    protected

    def set_dossier
      @dossier = Dossier.find(params[:dossier_id])
    end

    def set_commune
      @commune = @dossier.commune
      @objets = @commune.objets.with_photos_first.includes(:commune, recensements: %i[photos_attachments photos_blobs])
    end

    def restrict_access
      if current_conservateur.nil?
        redirect_to root_path, alert: "Veuillez vous connecter"
      elsif current_conservateur.departements.exclude?(@commune.departement)
        redirect_to root_path, alert: "Vous n'avez pas accès au département de cet objet"
      end
    end

    def restrict_commune_completed
      return true if @commune.completed?

      redirect_with_alert("La commune n'a pas encore terminé le recensement")
    end

    def prevent_pending_recensements
      return true if @dossier.recensements.not_analysed.empty?

      redirect_with_alert("Il reste des recensements à analyser")
    end

    def restrict_dossier_submitted
      return true if @dossier.submitted?

      alert = {
        construction: "La commune n'a pas terminé le recensement",
        rejected: "L dossier a été renvoyé à la commune, il faut attendre son retour",
        accepted: "Le rapport a déjà été envoyé"
      }[@dossier.status.to_sym]
      redirect_with_alert(alert)
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
