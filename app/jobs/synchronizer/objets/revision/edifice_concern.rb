# frozen_string_literal: true

module Synchronizer
  module Objets
    module Revision
      module EdificeConcern
        extend ActiveSupport::Concern

        def new_edifice?
          edifice_attributes.key?(:edifice_attributes)
        end

        private

        def edifice_attributes
          @edifice_attributes ||= compute_edifice_attributes
        end

        def compute_edifice_attributes
          if existing_edifice_by_ref && existing_edifice_by_ref.code_insee == @objet_attributes[:lieu_actuel_code_insee]
            { edifice_id: existing_edifice_by_ref.id }
          elsif existing_edifice_by_code_insee_and_slug
            { edifice_id: existing_edifice_by_code_insee_and_slug.id }
          elsif existing_edifice_by_ref &&
                existing_edifice_by_ref.code_insee != @objet_attributes[:lieu_actuel_code_insee]
            # l’édifice trouvé via le REFA est dans une autre commune, on ne l’utilise pas pour cet
            # objet et on en créé un nouveau dans la bonne commune sans REFA pour éviter un conflit
            { edifice_attributes: new_edifice_attributes.except(:merimee_REF) }
          else
            { edifice_attributes: new_edifice_attributes }
          end
        end

        def existing_edifice_by_ref = @eager_loaded_records.edifice_by_ref
        def existing_edifice_by_code_insee_and_slug = @eager_loaded_records.edifice_by_code_insee_and_slug

        def new_edifice_attributes
          {
            merimee_REF: @objet_attributes[:lieu_actuel_edifice_ref].presence,
            code_insee: @objet_attributes[:lieu_actuel_code_insee],
            slug: ::Edifice.slug_for(@objet_attributes[:lieu_actuel_edifice_nom]),
            nom: @objet_attributes[:lieu_actuel_edifice_nom]
          }
        end
      end
    end
  end
end
