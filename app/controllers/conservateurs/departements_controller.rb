# frozen_string_literal: true

module Conservateurs
  class DepartementsController < BaseController
    before_action :set_departement, only: [:show]

    def index
      @departements = policy_scope(Departement).include_communes_count.include_objets_count
    end

    def show
      @stats = Co::DepartementStats.new(@departement.code)
      if params[:vue] == "carte"
        set_communes
        set_departement_json
        render "show_map"
      else
        @communes_search = Co::Conservateurs::CommunesSearch.new(
          @departement, params, scoped_communes: policy_scope(Commune)
        )
      end
    end

    protected

    def set_departement
      @departement = Departement.find(params[:id])
      authorize(@departement)
    end

    def set_departement_json
      @departement_json = {
        code: @departement.code,
        bounding_box_ne: @departement.bounding_box_ne.coordinates,
        bounding_box_sw: @departement.bounding_box_sw.coordinates
      }.to_json
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

    def active_nav_links = ["Mes départements"] + (@departement ? [@departement.to_s] : [])
  end
end
