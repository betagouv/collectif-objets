# frozen_string_literal: true

module Communes
  class CompletionsController < BaseController
    before_action :restrict_not_started, except: [:show]
    before_action :restrict_completed, only: [:show]
    before_action :set_objets
    before_action :set_missing_photos, only: %i[new create]

    def show; end

    def new; end

    def create
      if @dossier.submit!(notes_commune: params[:commune][:dossier_attributes][:notes_commune])
        after_create
        redirect_to commune_objets_path(@commune), notice: "Le recensement de votre commune est terminé !"
      else
        render :new, status: :unprocessable_entity
      end
    end

    protected

    def restrict_not_started
      if @commune.inactive?
        redirect_with_alert "Vous devez recenser tous les objets avant de finaliser le dossier"
      elsif @commune.completed?
        redirect_with_alert "Votre dossier de recensement a déjà été envoyé"
      end
    end

    def restrict_completed
      return true if @commune.completed?

      redirect_with_alert "Le recensement de votre commune n'est pas encore terminé !"
    end

    def redirect_with_alert(alert)
      redirect_to commune_objets_path(@commune), alert:
    end

    def set_objets
      @objets = @commune.objets.joins(:recensements)
        .includes(:commune, recensements: %i[photos_attachments photos_blobs])
    end

    def after_create
      SendMattermostNotificationJob.perform_async("commune_completed", { "commune_id" => @commune.id })
      UserMailer.with(user_id: current_user.id, commune_id: @commune.id).commune_completed_email.deliver_later
    end

    def set_missing_photos
      @missing_photos = @dossier.recensements.any?(&:missing_photos?)
    end
  end
end
