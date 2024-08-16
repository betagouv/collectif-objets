# frozen_string_literal: true

module Conservateurs
  class FichesController < BaseController
    def index
      @communes = policy_scope(Commune)
        .joins(:recensements).where("cardinality(recensements.analyse_fiches) > 0")
        .includes(:recensements)
        .group(:id, "objets_count", "recensements.id")
        .order(:nom)
    end

    private

    def active_nav_links = ["Mes actions", "Fiches attribuées"]
  end
end
