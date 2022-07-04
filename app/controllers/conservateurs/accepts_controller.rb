# frozen_string_literal: true

module Conservateurs
  class AcceptsController < ApplicationController
    before_action :set_dossier, :set_commune, :restrict_access, :restrict_commune_completed,
                  :restrict_dossier_submitted, :prevent_pending_recensements

    def new
      @dossier.update!(conservateur_id: current_conservateur.id)
    end

    def create
      if @dossier.accept!(conservateur_id: current_conservateur.id)
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

      redirect_with_alert("Le rapport ne peut pas être généré car la commune n'a pas terminé le recensement")
    end

    def prevent_pending_recensements
      return true if @dossier.recensements.not_analysed.empty?

      redirect_with_alert("Le rapport ne peut pas être généré car il reste des recensements à analyser")
    end

    def restrict_dossier_submitted
      return true if @dossier.submitted?

      alert = {
        construction: "Le rapport ne peut pas être généré car la commune n'a pas terminé le recensement",
        rejected: "Le rapport ne peut pas être généré car le dossier a été renvoyé à la commune,"\
                  " il faut attendre son retour",
        accepted: "Le rapport a déjà été envoyé"
      }[@dossier.status.to_sym]
      redirect_with_alert(alert)
    end

    def redirect_with_alert(alert)
      redirect_to conservateurs_commune_path(@commune), alert:
    end
  end
end
