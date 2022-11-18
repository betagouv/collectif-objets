# frozen_string_literal: true

module Conservateurs
  class DossiersController < BaseController
    before_action :set_dossier, :set_commune, :restrict_access, :restrict_accepted

    def show; end

    protected

    def set_dossier
      @dossier = Dossier.find(params[:id])

      raise unless current_conservateur.departements.include?(@dossier.commune.departement)
    end

    def set_commune
      @commune = @dossier.commune
    end

    def restrict_access
      return true if current_conservateur&.departements&.include?(@commune.departement)

      redirect_to root_path, alert: "Veuillez vous connecter en tant que conservateur"
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
