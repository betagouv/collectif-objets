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
    end
  end
end

# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/MethodLength
