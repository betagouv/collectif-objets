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
              SELECT objets."palissy_INSEE", COUNT(*) recensements_prioritaires_count
              FROM recensements
              LEFT JOIN objets ON recensements.objet_id = objets.id
              WHERE (#{Recensement::RECENSEMENT_PRIORITAIRE_SQL})
              GROUP BY "palissy_INSEE"
            ) d ON d."palissy_INSEE" = communes.code_insee
          }.squish
        ).select("communes.*, COALESCE(d.recensements_prioritaires_count, 0) AS recensements_prioritaires_count")
      end

      ransacker(:recensements_prioritaires_count) { Arel.sql("recensements_prioritaires_count") }
    end
  end
end

# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/MethodLength
