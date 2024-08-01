# frozen_string_literal: true

module Conservateurs
  class DepartementsController < BaseController
    before_action :set_departement, only: [:show]

    def index
      @departements = policy_scope(Departement).include_objets_count.order(:code)
    end

    def show
      @stats = Co::DepartementStats.new(@departement)
      set_communes
      if params[:vue] == "carte"
        @communes.select(%w[code_insee nom status objets_count en_peril_count latitude longitude]).to_a
        set_departement_json
        render "show_map"
      else
        set_status_global_filter
        @ransack = @communes.select("nom").ransack(params[:q])

        # Remonte par défaut les communes avec le plus d'objets en péril
        @ransack.sorts = "en_peril_count DESC" if @ransack.sorts.empty?
        @ransack.sorts = "nom ASC" unless @ransack.sorts.collect(&:attr).include? "unaccent(nom)"

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
      @communes = @departement.communes.include_statut_global
    end

    def set_status_global_filter
      # Si l'utilisateur choisit un statut à filtrer, le conserver en session
      if params[:q] && params[:q][:statut_global_eq]
        session[:statut_global_eq] = params[:q][:statut_global_eq]
      elsif session[:statut_global_eq] # sinon, on le renvoie sur le statut choisi précédemment
        redirect_to conservateurs_departement_path(@departement, q: { statut_global_eq: session[:statut_global_eq] })
      end
    end

    def active_nav_links = ["Mes départements"] + (@departement ? [@departement.to_s] : [])
  end
end
