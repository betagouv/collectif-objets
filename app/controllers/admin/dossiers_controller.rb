# frozen_string_literal: true

module Admin
  class DossiersController < BaseController
    def show
      @dossier = Dossier.find(params[:id])
      @commune = @dossier.commune # Requis par shared/dossier_rapport
    end

    private

    def active_nav_links = %w[Communes]
  end
end
