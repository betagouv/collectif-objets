# frozen_string_literal: true

require "active_support/concern"

module Dossiers
  module IncludeCountsConcern
    extend ActiveSupport::Concern

    included do
      # Tous les objets de la commune
      def self.include_objets_count
        joins(%{
          LEFT JOIN (
            SELECT communes.id, COUNT(*) AS objets_count
              FROM communes
              INNER JOIN objets ON communes.code_insee = "objets".lieu_actuel_code_insee
              GROUP BY communes.id
          ) AS nombre_objets_par_commune
          ON nombre_objets_par_commune.id = dossiers.commune_id
        }).select("COALESCE(objets_count, 0) AS objets_count")
      end

      ransacker(:nombre_objets) { Arel.sql("objets_count") }
    end
  end
end
