# frozen_string_literal: true

module Conservateurs
  class DossiersController < BaseController
    before_action :set_commune

    def historique
      @dossiers = policy_scope(Dossier).where(commune: @commune, status: :archived).order(archived_at: :desc)
    end

    def show
      @dossier = @commune.dossier
      authorize(@dossier)
    end

    protected

    def set_commune
      @commune = Commune.find(params[:commune_id])
      authorize(@commune)
    end

    def active_nav_links = ["Mes départements", @commune.departement.to_s]
  end
end
