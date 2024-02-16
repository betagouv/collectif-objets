# frozen_string_literal: true

module Synchronizer
  module Communes
    module Batch
      # Groups SQL queries and stores dependent records in indexed hashes. Avoids N+1 queries
      class EagerLoadStore
        def initialize(batch)
          @batch = batch
        end

        def communes_by_code_insee
          @communes_by_code_insee ||= Commune
            .where(code_insee: @batch.unique_code_insees)
            .includes(:users)
            .to_a
            .index_by(&:code_insee)
        end

        def objets_count_by_code_insee
          @objets_count_by_code_insee ||=
            Hash.new(0).merge(
              Objet
                .where(lieu_actuel_code_insee: @batch.unique_code_insees)
                .group(:lieu_actuel_code_insee)
                .count
            )
        end
      end
    end
  end
end
