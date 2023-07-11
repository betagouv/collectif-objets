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
            SELECT communes.id, COUNT(*) AS nombre_objets
              FROM communes
              INNER JOIN objets ON communes.code_insee = "objets"."palissy_INSEE"
              GROUP BY communes.id
          ) AS nombre_objets_par_commune
          ON nombre_objets_par_commune.id = dossiers.commune_id
        }).select("COALESCE(nombre_objets, 0) AS nombre_objets")
      end

      ransacker(:nombre_objets) { Arel.sql("nombre_objets") }
    end
  end
end
