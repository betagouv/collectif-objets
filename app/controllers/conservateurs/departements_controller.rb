# frozen_string_literal: true

module Conservateurs
  class DepartementsController < ApplicationController
    before_action :restrict_access

    def index
      @departements = current_conservateur.departements
    end

    def show
      @departement = params[:id]
      @campaign = Co::Campaign.for_departement(@departement)
      @stats = Co::DepartementStats.new(@departement)
      @communes_search = Co::Conservateurs::CommunesSearch.new(@departement, params)
    end

    protected

    def restrict_access
      return true if params[:id] && current_conservateur&.departements&.include?(params[:id])

      return true if params[:id].blank? && current_conservateur.present?

      redirect_to root_path, alert: "Veuillez vous connecter"
    end
  end
end
