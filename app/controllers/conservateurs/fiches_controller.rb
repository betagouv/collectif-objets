# frozen_string_literal: true

module Conservateurs
  class FichesController < BaseController
    def index
      @dossiers = policy_scope(Dossier).where(conservateur: current_conservateur)
    end

    private

    def active_nav_links = ["Mes actions", "Fiches attribuées"]
  end
end
