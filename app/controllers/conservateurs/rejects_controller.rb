# frozen_string_literal: true

module Conservateurs
  class RejectsController < ApplicationController
    before_action :set_dossier, :set_commune, :restrict_access, :restrict_commune_completed, :restrict_dossier_submitted

    def new; end

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

    def create
      if @dossier.reject!
        UserMailer.with(dossier: @dossier).dossier_rejected_email.deliver_later
        redirect_to conservateurs_commune_path(@commune, warning: "Le dossier a été renvoyé à la commune")
      else
        render "conservateurs/rejects/new", status: :unprocessable_entity
      end
    end

    protected

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

    def restrict_commune_completed
      return true if @commune.completed?

      redirect_with_alert "La commune n'a pas terminé le recensement"
    end

    def restrict_dossier_submitted
      return true if @dossier.submitted?

      alert = {
        construction: "Le renvoi du dossier n'est pas possible car la commune n'a pas terminé le recensement",
        rejected: "Le dossier a déjà été renvoyé à la commune, il faut attendre son retour",
        accepted: "Le renvoi du dossier n'est plus possible car le rapport a déjà été envoyé"
      }[@dossier.status.to_sym]
      redirect_with_alert alert
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
