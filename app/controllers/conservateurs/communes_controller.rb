# frozen_string_literal: true

module Conservateurs
  class CommunesController < BaseController
    before_action :set_commune, :set_dossier, only: [:show]
    skip_after_action :verify_authorized, only: [:autocomplete]

    def show
      return show_analyse_saved if params[:analyse_saved].present?

      @edifices = Edifice.where(code_insee: @commune.code_insee).preloaded
    end

    def autocomplete
      render_turbo_stream_update \
        "js-header-search-results",
        partial: "conservateurs/communes/autocomplete_results",
        locals: { communes: communes_autocomplete_arel, search_query: params[:nom] }
    end

    protected

    def show_analyse_saved
      @objets = @commune
        .objets
        .includes(:edifice, recensement: { photos_attachments: :blob })
        .a_examiner
        .order_by_recensement_priorite
      render "show_analyse_saved"
    end

    def set_commune
      @commune = Commune.includes(:departement).find(params[:id])
      authorize(@commune)
    end

    def set_dossier
      @dossier = @commune.dossier
      @dossier&.recensements&.load
    end

    def set_departement
      @departement = params[:departement_id]
    end

    def communes_autocomplete_arel
      policy_scope(Commune)
        .limit(5)
        .ransack(nom_unaccented_cont: params[:nom], s: "nom asc")
        .result
    end

    def active_nav_links = ["Mes départements"] + (@commune ? [@commune.departement.to_s] : [])
  end
end
