# frozen_string_literal: true

module Communes
  class DossiersController < BaseController
    before_action :set_dossier

    def show; end

    protected

    def set_dossier
      @dossier = Dossier.find_by(id: params[:id], commune_id: params[:commune_id])
      authorize(@dossier)
    end
  end
end
