# frozen_string_literal: true

module Conservateurs
  class CommunesController < BaseController
    before_action :set_commune, :set_dossier, only: [:show]
    skip_after_action :verify_authorized, only: [:autocomplete]

    def show
      return show_analyse_saved if params[:analyse_saved].present?

      @edifices = @commune
        .edifices
        .ordered_by_nom
        .includes(objets: { edifice: [], recensements: %i[photos_attachments photos_blobs] })
    end

    def autocomplete
      render_turbo_stream_update(
        "js-header-search-results",
        partial: "conservateurs/communes/autocomplete_results",
        locals: { communes: communes_autocomplete_arel, search_query: params[:nom] }
      )
    end

    protected

    def show_analyse_saved
      @objets = @dossier
        .objets
        .includes(:edifice, recensements: %i[photos_attachments photos_blobs])
        .where(recensements: { analysed_at: nil })
        .order_by_recensement_priorite
      render "show_analyse_saved"
    end

    def set_commune
      @commune = Commune.find(params[:id])
      authorize(@commune)
    end

    def set_dossier
      @dossier = @commune.dossier
    end

    def set_departement
      @departement = params[:departement_id]
    end

    def communes_autocomplete_arel
      policy_scope(Commune)
        .where(departement: current_conservateur.departements)
        .search_by_nom(params[:nom])
        .order("nom ASC")
        .first(5)
    end

    def active_nav_links = ["Mes départements"] + (@commune ? [@commune.departement.to_s] : [])
  end
end
