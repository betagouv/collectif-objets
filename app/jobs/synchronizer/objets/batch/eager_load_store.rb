# frozen_string_literal: true

module Synchronizer
  module Objets
    module Batch
      # Groups SQL queries and stores dependent records in indexed hashes. Avoids N+1 queries
      class EagerLoadStore
        include LogConcern

        def initialize(batch, logger: nil)
          @batch = batch
          @logger = logger
        end

        def objets_by_ref
          @objets_by_ref ||= Objet
            .where(palissy_REF: @batch.unique_palissy_REFs)
            .includes(:commune, :recensements)
            .to_a
            .index_by(&:palissy_REF)
        end

        def communes_by_code_insee
          @communes_by_code_insee ||=
            Commune
              .where(code_insee: @batch.unique_code_insees)
              .to_a
              .index_by(&:code_insee)
        end

        def edifices_by_code_insee_and_slug
          @edifices_by_code_insee_and_slug ||= begin
            wheres = @batch.all_objets_attributes.map do |objet_attributes|
              Edifice.where(
                code_insee: objet_attributes[:lieu_actuel_code_insee],
                slug: Edifice.slug_for(objet_attributes[:lieu_actuel_edifice_nom])
              )
            end
            wheres.reduce(:or)
              .to_a
              .index_by { |edifice| [edifice.code_insee, edifice.slug] }
          end
        end

        def edifices_by_ref
          @edifices_by_ref ||=
            Edifice
              .where(merimee_REF: @batch.all_objets_attributes.pluck(:lieu_actuel_edifice_ref).map(&:presence).compact)
              .to_a
              .index_by(&:merimee_REF)
        end

        def add_edifice(edifice)
          log "édifice créé #{edifice.attributes.slice(*%w[code_insee merimee_REF slug nom id])}"
          edifices_by_code_insee_and_slug[[edifice.code_insee, edifice.slug]] = edifice
          edifices_by_ref[edifice.merimee_REF] = edifice if edifice.merimee_REF.present?
        end
      end
    end
  end
end
