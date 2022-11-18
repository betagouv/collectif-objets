# frozen_string_literal: true

module Communes
  class CompletionsController < BaseController
    before_action :set_completion_and_authorize
    before_action :set_objets
    before_action :set_missing_photos, only: %i[new create]

    def show; end

    def new; end

    def create
      if @completion.create!(**completion_params)
        redirect_to commune_objets_path(@commune), notice: "Le recensement de votre commune est terminé !"
      else
        render :new, status: :unprocessable_entity
      end
    end

    protected

    def set_completion_and_authorize
      @completion = Completion.new(dossier: @dossier)
      authorize(@completion)
    end

    def redirect_with_alert(alert)
      redirect_to commune_objets_path(@commune), alert:
    end

    def set_objets
      @objets = @commune.objets.joins(:recensements)
        .includes(:commune, recensements: %i[photos_attachments photos_blobs])
    end

    def set_missing_photos
      @missing_photos = @dossier.recensements.any?(&:missing_photos?)
    end

    def completion_params
      params.require(:completion).permit(:notes_commune).to_h.symbolize_keys
        .merge(user: current_user)
    end
  end
end
