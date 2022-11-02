# frozen_string_literal: true

module Conservateurs
  class RecensementsController < ApplicationController
    before_action :set_recensement, :set_objet, :restrict_access, :prevent_not_completed

    def edit; end

    def update
      if @recensement.update(recensement_params)
        redirect_to conservateurs_commune_path(@objet.commune, analyse_saved: true)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    protected

    def set_recensement
      @recensement ||= Recensement.find(params[:id])
      @recensement_presenter = RecensementPresenter.new(@recensement) if @recensement
    end

    def set_objet
      @objet = @recensement.objet
    end

    def dossier
      @dossier ||= @recensement.dossier
    end

    def restrict_access
      if current_conservateur.nil?
        redirect_to root_path, alert: "Veuillez vous connecter en tant que conservateur"
      elsif current_conservateur.departements.exclude?(@recensement.objet.commune.departement)
        redirect_to root_path, alert: "Vous n'avez pas accès au département de cet objet"
      end
    end

    def prevent_not_completed
      return true if @objet.commune.completed?

      redirect_to conservateurs_commune_path(@objet.commune), alert: I18n.t("recensement.analyse.not_completed")
    end

    def recensement_params
      recensement_params_permitted
        .transform_values { |v| v.is_a?(Array) ? v.map(&:presence).compact : v }
        .merge(
          confirmation: true,
          analysed_at: Time.zone.now,
          conservateur_id: current_conservateur.id
        )
        .merge(@recensement.photos.empty? ? { skip_photos: true } : {})
    end

    def recensement_params_permitted
      params
        .require(:recensement)
        .permit(
          :analyse_etat_sanitaire, :analyse_etat_sanitaire_edifice,
          :analyse_securisation, :analyse_notes,
          analyse_actions: [], analyse_fiches: []
        )
    end
  end
end
