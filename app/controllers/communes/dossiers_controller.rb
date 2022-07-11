# frozen_string_literal: true

module Communes
  class DossiersController < BaseController
    before_action :set_dossier, :restrict_accepted, only: [:show]

    def show; end

    protected

    def set_dossier
      @dossier = Dossier.find_by(id: params[:id], commune_id: params[:commune_id])
    end

    def restrict_accepted
      return true if @dossier.accepted?

      redirect_to(
        commune_objets_path(@commune),
        alert: "Le dossier de recensement de votre commune nʼa pas été accepté !"
      )
    end
  end
end
