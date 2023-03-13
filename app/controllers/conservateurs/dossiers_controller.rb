# frozen_string_literal: true

module Conservateurs
  class DossiersController < BaseController
    before_action :set_dossier, :set_commune

    def show; end

    protected

    def set_dossier
      if params[:id].present?
        @dossier = Dossier.find(params[:id])
      elsif params[:commune_id].present?
        @dossier = Commune.find(params[:commune_id]).dossier
      end
      authorize(@dossier)
    end

    def set_commune
      @commune = @dossier.commune
    end
  end
end
