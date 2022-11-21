# frozen_string_literal: true

module Communes
  class RecompletionsController < BaseController
    before_action :set_dossier_recompletion, :set_objets

    def new; end

    def create
      if @dossier_recompletion.create!(**dossier_recompletion_params)
        redirect_to commune_objets_path(@commune), notice: "Votre dossier a été renvoyé au conservateur"
      else
        render :new, status: :unprocessable_entity
      end
    end

    protected

    def set_dossier_recompletion
      @dossier_recompletion = DossierRecompletion.new(dossier: @dossier)
      authorize(@dossier_recompletion)
    end

    def set_objets
      @objets = @commune.objets.joins(:recensements)
        .includes(:commune, recensements: %i[photos_attachments photos_blobs])
    end

    def dossier_recompletion_params
      params.require(:dossier_recompletion).permit(:notes_commune).to_h.symbolize_keys
    end
  end
end
