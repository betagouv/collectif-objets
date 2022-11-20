# frozen_string_literal: true

module Communes
  class RecompletionsController < BaseController
    before_action :set_recompletion, :set_objets

    def new; end

    def create
      if @recompletion.create!(**recompletion_params)
        redirect_to commune_objets_path(@commune), notice: "Votre dossier a été renvoyé au conservateur"
      else
        render :new, status: :unprocessable_entity
      end
    end

    protected

    def set_recompletion
      @recompletion = Recompletion.new(dossier: @dossier)
      authorize(@recompletion)
    end

    def set_objets
      @objets = @commune.objets.joins(:recensements)
        .includes(:commune, recensements: %i[photos_attachments photos_blobs])
    end

    def recompletion_params
      params.require(:recompletion).permit(:notes_commune).to_h.symbolize_keys
    end
  end
end
