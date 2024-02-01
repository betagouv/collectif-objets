# frozen_string_literal: true

module Synchronizer
  module Objets
    module Batch
      # picks dependent records from the EagerLoadStore
      class EagerLoadedRecords
        def initialize(objet_attributes, eager_loader)
          @objet_attributes = objet_attributes
          @eager_loader = eager_loader
        end

        def objet
          @eager_loader.objets_by_ref[@objet_attributes[:palissy_REF]]
        end

        def commune
          @eager_loader.communes_by_code_insee[@objet_attributes[:palissy_INSEE]]
        end

        def edifice_by_ref
          return if @objet_attributes[:palissy_REFA].blank?

          @eager_loader.edifices_by_ref[@objet_attributes[:palissy_REFA]]
        end

        def edifice_by_code_insee_and_slug
          @eager_loader.edifices_by_code_insee_and_slug[
            [
              @objet_attributes[:palissy_INSEE],
              ::Edifice.slug_for(@objet_attributes[:palissy_EDIF])
            ]
          ]
        end
      end
    end
  end
end
