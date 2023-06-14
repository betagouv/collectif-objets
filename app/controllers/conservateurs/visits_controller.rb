# frozen_string_literal: true

module Conservateurs
  class VisitsController < BaseController
    def index
      @dossiers = policy_scope(Dossier).where(conservateur: current_conservateur).to_visit
        .joins(:commune)
        .includes(:commune)
        .select("dossiers.*, communes.nom AS nom_commune")
        .joins(%{
          LEFT JOIN (
            SELECT communes.id, COUNT(*) AS nombre_objets
              FROM communes
              INNER JOIN objets ON communes.code_insee = "objets"."palissy_INSEE"
              GROUP BY communes.id
          ) AS nombre_objets_par_commune
          ON nombre_objets_par_commune.id = dossiers.commune_id
        }).select("COALESCE(nombre_objets, 0) AS nombre_objets")
        .joins(%{
          LEFT JOIN (
            SELECT recensements.dossier_id, COUNT(*) AS nombre_objets_prioritaires
            FROM recensements
            WHERE recensements.localisation = 'absent'
            OR (recensements.etat_sanitaire IN ('mauvais', 'peril') AND recensements.analyse_etat_sanitaire IS NULL)
            OR recensements.analyse_etat_sanitaire IN ('mauvais', 'peril')
            GROUP BY recensements.dossier_id
          ) AS nombre_objets_prioritaires_par_dossier
          ON nombre_objets_prioritaires_par_dossier.dossier_id = dossiers.id
        }).select("COALESCE(nombre_objets_prioritaires, 0) AS nombre_objets_prioritaires")
    end

    private

    def active_nav_links = ["Mes actions", "Visites prévues"]
  end
end
