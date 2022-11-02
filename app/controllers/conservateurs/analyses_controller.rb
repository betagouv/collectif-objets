# frozen_string_literal: true

module Conservateurs
  class AnalysesController < ApplicationController
    before_action :set_recensement, :set_objet, :restrict_access_conservateur, :restrict_not_completed

    def edit; end

    def update
      if @recensement.update(analyse_recensement_params)
        redirect_to conservateurs_commune_path(@objet.commune, analyse_saved: true)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    protected

    def set_recensement
      @recensement ||= Recensement.find(params[:recensement_id])
      @recensement_presenter = RecensementPresenter.new(@recensement) if @recensement
    end

    def set_objet
      @objet = @recensement.objet
    end

    def dossier
      @dossier ||= @recensement.dossier
    end

    def restrict_access_conservateur
      if current_conservateur.nil?
        redirect_to root_path, alert: "Veuillez vous connecter en tant que conservateur"
      elsif current_conservateur.departements.exclude?(@recensement.objet.commune.departement)
        redirect_to root_path, alert: "Vous n'avez pas accès au département de cet objet"
      end
    end

    def restrict_not_completed
      return true if @objet.commune.completed?

      redirect_to conservateurs_commune_path(@objet.commune), alert: I18n.t("recensement.analyse.not_completed")
    end

    def analyse_recensement_params
      @analyse_recensement_params ||=
        Co::Recensements::AnalyseParamsParser.new(params).parse
          .merge(@recensement.photos.empty? ? { skip_photos: true } : {})
    end
  end
end
