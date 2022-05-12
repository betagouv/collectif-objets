# frozen_string_literal: true

module Conservateurs
  class RecensementsController < ApplicationController
    before_action :set_recensement, :set_objet, :restrict_access, :prevent_not_completed

    def update
      return update_prioritaire if params[:recensement][:analyse_prioritaire].present?

      if @recensement.update(recensement_params)
        dossier.pdf.purge_later
        redirect_to conservateurs_commune_path(@objet.commune, analyse_saved: true)
      else
        render "conservateurs/objets/show", status: :unprocessable_entity
      end
    end

    def update_prioritaire
      res = @recensement.update(recensement_params_prioritaire)
      raise "Error on save: #{@recensement.errors.full_messages.first}" unless res

      render_turbo_stream_update(
        "js-recensement-prioritaire",
        partial: "conservateurs/objets/recensement_prioritaire",
        locals: { recensement: @recensement }
      )
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
        redirect_to root_path, alert: "Veuillez vous connecter"
      elsif current_conservateur.departements.exclude?(@recensement.objet.commune.departement)
        redirect_to root_path, alert: "Vous n'avez pas accès au département de cet objet"
      end
    end

    def prevent_not_completed
      return true if @objet.commune.completed?

      redirect_to conservateurs_objet_path(@objet), alert: I18n.t("recensement.analyse.not_completed")
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

    def recensement_params_prioritaire
      params
        .require(:recensement)
        .permit(:analyse_prioritaire)
        .merge(confirmation: true)
        .merge(@recensement.photos.empty? ? { skip_photos: true } : {})
        .transform_values { |v| v.to_s == "true" }
    end
  end
end
