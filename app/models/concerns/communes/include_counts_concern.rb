# frozen_string_literal: true

require "active_support/concern"

module Communes
  module IncludeCountsConcern
    extend ActiveSupport::Concern

    included do
      # Tous les objets de la commune
      def self.include_objets_count
        joins(
          %{
          LEFT OUTER JOIN (
            SELECT "palissy_INSEE", COUNT(*) objets_count
            FROM objets
            GROUP BY "palissy_INSEE"
          ) a ON a."palissy_INSEE" = communes.code_insee
          }.squish
        ).select("communes.*, COALESCE(a.objets_count, 0) AS objets_count")
      end

      ransacker(:objets_count) { Arel.sql("objets_count") }

      # Objets recensés sur CO
      def self.include_objets_recenses_count
        joins(
          %{
          LEFT OUTER JOIN (
            SELECT "palissy_INSEE", COUNT(*) objets_recenses_count
            FROM objets
            WHERE exists (SELECT id FROM recensements WHERE recensements.objet_id = objets.id)
            GROUP BY "palissy_INSEE"
          ) b ON b."palissy_INSEE" = communes.code_insee

          LEFT OUTER JOIN (
            SELECT objets."palissy_INSEE", COUNT(*) recensements_analysed_count
            FROM recensements
            INNER JOIN objets ON objets.id = recensements.objet_id
            WHERE recensements.analysed_at IS NOT NULL
            GROUP BY objets."palissy_INSEE"
          ) c ON c."palissy_INSEE" = communes.code_insee

          LEFT OUTER JOIN (
            SELECT objets."palissy_INSEE", COUNT(*) recensements_prioritaires_count
            FROM recensements
            INNER JOIN objets ON objets.id = recensements.objet_id
            WHERE (#{Recensement::RECENSEMENT_PRIORITAIRE_SQL})
            GROUP BY objets."palissy_INSEE"
          ) d ON d."palissy_INSEE" = communes.code_insee
        }
        ).select(
          "communes.*," \
          "COALESCE(b.objets_recenses_count, 0) AS objets_recenses_count, " \
          "(COALESCE(100 * b.objets_recenses_count, 0)::float / COALESCE(a.objets_count, 1)) " \
          "AS objets_recenses_percentage, " \
          "(COALESCE(100 * c.recensements_analysed_count, 0)::float / COALESCE(a.objets_count, 1)) " \
          "AS recensements_analysed_percentage," \
          "COALESCE(d.recensements_prioritaires_count, 0) as recensements_prioritaires_count"
        )
      end

      # Objets recensés et prioritaires d'une commune
      def self.include_recensements_prioritaires_count
        joins(
          %{
            LEFT OUTER JOIN (
              #{Recensement.select(%{objets."palissy_INSEE", COUNT(*) })
                .left_outer_joins(:objet)
                .where(Recensement::RECENSEMENT_EN_PERIL_SQL)
                .group(:palissy_INSEE).to_sql}
            ) AS recensements_en_peril
            ON recensements_en_peril."palissy_INSEE" = communes.code_insee

            LEFT OUTER JOIN (
              #{Recensement.select(%{objets."palissy_INSEE", COUNT(*) })
                .left_outer_joins(:objet)
                .where(Recensement::RECENSEMENT_ABSENT_SQL)
                .group(:palissy_INSEE).to_sql}
            ) AS recensements_disparus
            ON recensements_disparus."palissy_INSEE" = communes.code_insee
          }.squish
        ).select(%{communes.*,
          COALESCE(recensements_en_peril.count, 0) AS recensements_en_peril_count,
          COALESCE(recensements_disparus.count, 0) AS recensements_disparus_count,
          COALESCE(recensements_en_peril.count, 0) + COALESCE(recensements_disparus.count, 0)
            AS recensements_prioritaires_count }.squish)
      end

      ransacker(:recensements_prioritaires_count) { Arel.sql("recensements_prioritaires_count") }
      ransacker(:types_recensements_prioritaires) do
        Arel.sql(%(
          CASE
            WHEN recensements_en_peril.count > 0 AND recensements_disparus.count > 0 THEN 'peril_disparu'
            WHEN recensements_en_peril.count > 0 AND recensements_disparus.count IS NULL THEN 'peril'
            WHEN recensements_en_peril.count IS NULL AND recensements_disparus.count > 0 THEN 'disparu'
            ELSE NULL
          END).squish)
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/MethodLength
