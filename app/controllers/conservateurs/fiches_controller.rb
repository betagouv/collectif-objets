# frozen_string_literal: true

module Conservateurs
  class FichesController < BaseController
    def index
      @dossiers = policy_scope(Dossier).where(conservateur: current_conservateur)
      .joins(:recensements).select("recensements.analyse_fiches").where("cardinality(recensements.analyse_fiches) > 0")
        .joins(:commune)
        # .includes(:commune)
        .select("dossiers.*, communes.nom AS nom_commune, communes.id")
        .include_objets_count
        .order(:nom_commune)
    end

    private

    def active_nav_links = ["Mes actions", "Fiches attribuées"]
  end
end
