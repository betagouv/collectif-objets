# frozen_string_literal: true

module Conservateurs
  class DepartementsController < ApplicationController
    before_action :restrict_access_index, only: [:index]
    before_action :set_departement, :restrict_access_show, only: [:show]

    def index
      @departements = current_conservateur.departements.include_communes_count.include_objets_count
    end

    def show
      @campaign = @departement.current_campaign
      @stats = Co::DepartementStats.new(@departement.code)
      if params[:vue] == "carte"
        set_communes
        render "show_map"
      else
        @communes_search = Co::Conservateurs::CommunesSearch.new(@departement.code, params)
      end
    end

    protected

    def restrict_access_index
      return true if current_conservateur.present?

      redirect_to root_path, alert: "Veuillez vous connecter en tant que conservateur"
    end

    def set_departement
      @departement = Departement.find(params[:id])
    end

    def restrict_access_show
      return true if current_conservateur&.departements&.include?(@departement)

      redirect_to root_path, alert: "Veuillez vous connecter en tant que conservateur"
    end

    def set_communes
      fields = %w[code_insee nom status objets_count recensements_prioritaires_count latitude longitude]
      @communes = @departement.communes
        .includes(:dossier)
        .include_objets_count
        .include_recensements_prioritaires_count
        .select(fields)
        .to_a
    end
  end
end
