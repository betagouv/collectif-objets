# frozen_string_literal: true

module Synchronizer
  module Objets
    module Batch
      # Groups SQL queries and stores dependent records in indexed hashes. Avoids N+1 queries
      class EagerLoadStore
        def initialize(batch)
          @batch = batch
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
          @edifices_by_code_insee_and_slug ||=
            @batch.all_objets_attributes
              .select { _1[:palissy_INSEE].present? }
              .map { Edifice.where(code_insee: _1[:palissy_INSEE], slug: Edifice.slug_for(_1[:palissy_EDIF])) }
              .reduce(:or)
              .to_a
              .index_by { |edifice| [edifice.code_insee, edifice.slug] }
        end

        def edifices_by_ref
          @edifices_by_ref ||=
            Edifice
              .where(merimee_REF: @batch.all_objets_attributes.pluck(:palissy_REFA).map(&:presence).compact)
              .to_a
              .index_by(&:merimee_REF)
        end

        def add_edifice(edifice)
          if edifice.merimee_REF.present?
            edifices_by_ref[edifice.merimee_REF] = edifice
          else
            edifices_by_code_insee_and_slug[[edifice.code_insee, edifice.slug]] = edifice
          end
        end
      end
    end
  end
end
