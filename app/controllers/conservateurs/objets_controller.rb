# frozen_string_literal: true

module Conservateurs
  class ObjetsController < ApplicationController
    before_action :set_objet, :restrict_access, :set_recensement

    def show; end

    protected

    def set_objet
      @objet = Objet.find(params[:id])
    end

    def set_recensement
      @recensement = @objet.current_recensement
      @recensement_presenter = RecensementPresenter.new(@recensement) if @recensement
    end

    def restrict_access
      if current_conservateur.nil?
        redirect_to root_path, alert: "Veuillez vous connecter en tant que conservateur"
      elsif current_conservateur.departements.exclude?(@objet.commune.departement)
        redirect_to root_path, alert: "Vous n'avez pas accès au département de cet objet"
      end
    end
  end
end
