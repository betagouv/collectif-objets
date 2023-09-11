# frozen_string_literal: true

require "active_support/concern"

module Communes
  module IncludeStatutGlobalConcern
    extend ActiveSupport::Concern

    included do
      def self.include_statut_global
        joins(%{
          LEFT OUTER JOIN (
            SELECT communes.code_insee, (CASE
                WHEN communes.status = 'inactive' THEN #{Commune::ORDRE_NON_RECENSÉ}
                WHEN communes.status = 'started' THEN #{Commune::ORDRE_EN_COURS_DE_RECENSEMENT}
                WHEN dossiers.status = 'submitted' AND recensements_analysed_count = 0
                  THEN #{Commune::ORDRE_NON_ANALYSÉ}
                WHEN dossiers.status = 'submitted' AND recensements_analysed_count > 0
                  THEN #{Commune::ORDRE_EN_COURS_D_ANALYSE}
                WHEN dossiers.status = 'accepted' then #{Commune::ORDRE_ANALYSÉ}
              END) AS statut_global
            FROM communes
            LEFT OUTER JOIN dossiers
            ON communes.dossier_id = dossiers.id
            LEFT OUTER JOIN (
              SELECT dossiers.id,
                SUM(CASE WHEN recensements.analysed_at IS NOT NULL THEN 1 ELSE 0 END) AS recensements_analysed_count
              FROM dossiers
              LEFT OUTER JOIN recensements
              ON dossiers.id = recensements.dossier_id
              GROUP BY dossiers.id
            ) AS nb_recensements_par_dossiers
            ON dossiers.id = nb_recensements_par_dossiers.id
          ) AS communes_statut_global
          ON communes.code_insee = communes_statut_global.code_insee
        }.squish)
        .select("communes.*, statut_global")
      end

      ransacker(:statut_global) { Arel.sql("statut_global") }
    end
  end
end
