# frozen_string_literal: true

module Conservateurs
  class DeletedRecensementsController < BaseController
    before_action :set_commune, :set_dossier, only: [:show]

    def show
      @deleted_recensements = @dossier.recensements.only_deleted
    end

    private

    def set_commune
      @commune = Commune.find(params[:commune_id])
      authorize(@commune)
    end

    def set_dossier
      @dossier = @commune.dossier
    end
  end
end
