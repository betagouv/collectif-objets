# frozen_string_literal: true

module Communes
  class CompletionsController < BaseController
    before_action :set_dossier_completion_and_authorize
    before_action :set_objets
    before_action :set_missing_photos, only: %i[new create]

    def show
      render "shared/completions/show"
    end

    def new
      render "shared/completions/new"
    end

    def create
      if @dossier_completion.create!(**dossier_completion_params)
        redirect_to commune_objets_path(@commune), notice: "Le recensement de votre commune est terminé !"
      else
        render :new, status: :unprocessable_content
      end
    end

    protected

    def set_dossier_completion_and_authorize
      @dossier_completion = DossierCompletion.new(dossier: @dossier)
      authorize(@dossier_completion)
    end

    def set_objets
      @objets = @dossier.objets
        .includes(:commune, recensement: %i[photos_attachments photos_blobs])
    end

    def set_missing_photos
      @missing_photos = @dossier.recensements.any?(&:missing_photos?)
    end

    def dossier_completion_params
      params.require(:dossier_completion).permit(:notes_commune, :recenseur).to_h.symbolize_keys
        .merge(user: current_user)
    end

    def active_nav_links = %w[Recensement]
  end
end
