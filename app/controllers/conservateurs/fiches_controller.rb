# frozen_string_literal: true

module Conservateurs
  class FichesController < BaseController
    def index
      policy_scope(Dossier)
    end

    private

    def active_nav_links = ["Mes actions", "Fiches attribuées"]
  end
end
