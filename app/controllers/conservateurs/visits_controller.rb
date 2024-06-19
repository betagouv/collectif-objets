# frozen_string_literal: true

module Conservateurs
  class VisitsController < BaseController
    def index
      @dossiers = policy_scope(Dossier).current.where(conservateur: current_conservateur).to_visit
        .joins(:commune)
        .includes(:commune)
        .select("dossiers.*, communes.nom AS nom_commune")
        .include_objets_count
        .joins(%{
          LEFT JOIN (
            SELECT recensements.dossier_id, COUNT(*) AS nombre_objets_prioritaires
            FROM recensements
            WHERE #{Recensement::RECENSEMENT_PRIORITAIRE_SQL}
            GROUP BY recensements.dossier_id
          ) AS nombre_objets_prioritaires_par_dossier
          ON nombre_objets_prioritaires_par_dossier.dossier_id = dossiers.id
        }).select("COALESCE(nombre_objets_prioritaires, 0) AS nombre_objets_prioritaires")
        .order(:visit, :nom_commune)
    end

    private

    def active_nav_links = ["Mes actions", "Déplacements prévus"]
  end
end
