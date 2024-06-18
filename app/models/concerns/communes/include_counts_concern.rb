# frozen_string_literal: true

require "active_support/concern"

module Communes
  module IncludeCountsConcern
    extend ActiveSupport::Concern

    included do
      # Tous les objets de la commune
      # À terme, ajouter un compteur d'objets dans la table de communes pour éviter cette requête
      def self.include_objets_count
        joins(
          %{
          LEFT OUTER JOIN (
            #{Objet.select(:lieu_actuel_code_insee, 'COUNT(*) AS objets_count').group(:lieu_actuel_code_insee).to_sql}
          ) a ON a.lieu_actuel_code_insee = communes.code_insee
          }.squish
        ).select("communes.*, COALESCE(a.objets_count, 0) AS objets_count")
      end

      ransacker(:objets_count) { Arel.sql("objets_count") }

      # Objets recensés et prioritaires d'une commune
      def self.include_recensements_prioritaires_count
        joins(
          %{
            LEFT OUTER JOIN (
              SELECT
                communes.id,
                SUM(CASE WHEN #{Recensement::RECENSEMENT_ABSENT_SQL} THEN 1 ELSE 0 END) AS disparus_count,
                SUM(CASE WHEN #{Recensement::RECENSEMENT_EN_PERIL_SQL} THEN 1 ELSE 0 END) AS en_peril_count
              FROM communes
              LEFT OUTER JOIN dossiers ON dossiers.commune_id = communes.id AND dossiers.status != 'archived'
              LEFT OUTER JOIN recensements ON recensements.deleted_at IS NULL AND recensements.dossier_id = dossiers.id
              WHERE #{Recensement::RECENSEMENT_PRIORITAIRE_SQL}
              GROUP BY communes.id
            ) AS recensements_prioritaires
            ON recensements_prioritaires.id = communes.id
          }.squish
        ).select(%(
          COALESCE(recensements_prioritaires.disparus_count, 0) AS disparus_count,
          COALESCE(recensements_prioritaires.en_peril_count, 0) AS en_peril_count
        ).squish)
      end

      ransacker(:en_peril_count) { Arel.sql("en_peril_count") }
      ransacker(:disparus_count) { Arel.sql("disparus_count") }
    end
  end
end

# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/MethodLength
