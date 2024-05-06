# frozen_string_literal: true

module Conservateurs
  class DepartementsController < BaseController
    before_action :set_departement, only: [:show]

    def index
      @departements = policy_scope(Departement).include_objets_count
    end

    def show
      @stats = Co::DepartementStats.new(@departement.code)
      if params[:vue] == "carte"
        set_communes
        set_departement_json
        render "show_map"
      else
        set_status_global_filter
        @ransack = policy_scope(Commune)
          .select("nom")
          .where(departement: @departement)
          .include_objets_count
          .include_recensements_prioritaires_count
          .include_statut_global
          .includes(:dossier)
          .ransack(params[:q])

        # Remonte par défaut les communes avec le plus d'objets en péril
        @ransack.sorts = "en_peril_count desc" if @ransack.sorts.empty?

        @pagy, @communes = pagy @ransack.result, items: 15
        @query_present = params[:q].present?
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
        boundingBox: @departement.bounding_box
      }.to_json
    end

    def set_communes
      fields = %w[code_insee nom status objets_count en_peril_count latitude longitude]
      @communes = policy_scope(Commune)
        .where(departement_code: @departement.code)
        .includes(:dossier)
        .include_objets_count
        .include_recensements_prioritaires_count
        .include_statut_global
        .select(fields)
        .to_a
    end

    def set_status_global_filter
      # Si l'utilisateur choisit un statut à filtrer, le conserver en session
      if params[:q] && params[:q][:statut_global_eq]
        session[:statut_global_eq] = params[:q][:statut_global_eq]
      else # sinon, on le renvoie sur le statut choisi précédemment
        redirect_to conservateurs_departement_path(@departement, q: { statut_global_eq: session[:statut_global_eq] })
      end
    end

    def active_nav_links = ["Mes départements"] + (@departement ? [@departement.to_s] : [])
  end
end
