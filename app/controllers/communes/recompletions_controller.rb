# frozen_string_literal: true

module Communes
  class RecompletionsController < BaseController
    before_action :restrict_dossier_status
    before_action :set_objets

    def new; end

    def create
      if @dossier.submit!(notes_commune: params[:commune][:dossier_attributes][:notes_commune])
        ConservateurMailer.with(dossier: @dossier)
          .commune_recompleted_email.deliver_later
        redirect_to commune_objets_path(@commune), notice: "Votre dossier a été renvoyé au conservateur"
      else
        render :new, status: :unprocessable_entity
      end
    end

    protected

    def restrict_dossier_status
      return true if @dossier.rejected?

      if @dossier.accepted?
        redirect_with_alert "Le dossier a déjà été accepté"
      elsif @dossier.construction?
        redirect_with_alert "Le dossier n'a pas encore été soumis pour analyse"
      end
    end

    def redirect_with_alert(alert)
      redirect_to commune_objets_path(@commune), alert:
    end

    def set_objets
      @objets = @commune.objets.joins(:recensements)
        .includes(:commune, recensements: %i[photos_attachments photos_blobs])
    end
  end
end
