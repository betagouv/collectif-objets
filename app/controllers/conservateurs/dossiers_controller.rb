# frozen_string_literal: true

module Conservateurs
  class DossiersController < BaseController
    before_action :set_commune, :set_dossier

    def show
      return unless params[:view] == "print"

      render :show_print, layout: "application_print"
    end

    protected

    def set_dossier
      @dossier = @commune.dossier
      authorize(@dossier) if @dossier
    end

    def set_commune
      @commune = Commune.find(params[:commune_id])
      authorize(@commune)
    end

    def active_nav_links = ["Mes départements", @dossier.departement.to_s]
  end
end
