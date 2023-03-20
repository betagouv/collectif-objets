# frozen_string_literal: true

module Conservateurs
  class VisitsController < BaseController
    def index
      @dossiers = policy_scope(Dossier).where(conservateur: current_conservateur).to_visit
    end

    private

    def active_nav_links = ["Mes actions", "Visites prévues"]
  end
end
