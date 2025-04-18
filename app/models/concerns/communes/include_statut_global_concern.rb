# frozen_string_literal: true

require "active_support/concern"

module Communes
  module IncludeStatutGlobalConcern
    extend ActiveSupport::Concern

    included do
      # Permet de récupérer le "statut global" sur toutes les communes
      def self.include_statut_global
        includes(:dossier)
        .joins(%{
          LEFT OUTER JOIN (
            SELECT communes.code_insee, COALESCE((CASE
                WHEN dossiers.status = 'construction' THEN #{Commune::ORDRE_EN_COURS_DE_RECENSEMENT}
                WHEN dossiers.status = 'accepted' then #{Commune::ORDRE_EXAMINÉ}
                WHEN dossiers.status = 'submitted' AND dossiers.replied_automatically_at IS NOT NULL
                  THEN #{Commune::ORDRE_A_EXAMINER}
                WHEN dossiers.status = 'submitted' AND recensements_analysed_count = 0
                  THEN #{Commune::ORDRE_EXAMEN_PRIORITAIRE}
                WHEN dossiers.status = 'submitted' AND recensements_analysed_count > 0
                  THEN #{Commune::ORDRE_EN_COURS_D_EXAMEN}
                END), #{Commune::ORDRE_NON_RECENSÉ}) AS statut_global,
                COALESCE(nb_recensements_par_communes.disparus_count, 0) AS disparus_count,
                COALESCE(nb_recensements_par_communes.en_peril_count, 0) AS en_peril_count
            FROM communes
            LEFT OUTER JOIN dossiers ON dossiers.commune_id = communes.id AND dossiers.status != 'archived'
            LEFT OUTER JOIN (
              SELECT communes.id,
                SUM(CASE WHEN recensements.analysed_at IS NOT NULL THEN 1 ELSE 0 END) AS recensements_analysed_count,
                SUM(CASE WHEN #{Recensement::RECENSEMENT_ABSENT_SQL} THEN 1 ELSE 0 END) AS disparus_count,
                SUM(CASE WHEN #{Recensement::RECENSEMENT_EN_PERIL_SQL} THEN 1 ELSE 0 END) AS en_peril_count
              FROM communes
              LEFT OUTER JOIN dossiers ON dossiers.commune_id = communes.id AND dossiers.status != 'archived'
              LEFT OUTER JOIN recensements ON recensements.deleted_at IS NULL AND recensements.dossier_id = dossiers.id
              GROUP BY communes.id
            ) AS nb_recensements_par_communes
            ON communes.id = nb_recensements_par_communes.id
          ) AS communes_statut_global
          ON communes.code_insee = communes_statut_global.code_insee
        }.squish)
        .select("communes.*, statut_global, disparus_count, en_peril_count")
      end

      ransacker(:statut_global) { Arel.sql("statut_global") }
      ransacker(:en_peril_count) { Arel.sql("en_peril_count") }
      ransacker(:disparus_count) { Arel.sql("disparus_count") }
    end
  end
end
