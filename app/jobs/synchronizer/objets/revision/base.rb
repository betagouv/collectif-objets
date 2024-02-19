# frozen_string_literal: true

module Synchronizer
  module Objets
    module Revision
      class Base
        include LogConcern

        def initialize(row:, objet_attributes:, eager_loaded_records:, logger: nil)
          @row = row
          @objet_attributes = objet_attributes
          @eager_loaded_records = eager_loaded_records
          @logger = logger
          @persisted_objet = @eager_loaded_records.objet
          @commune_before_update = persisted_objet.commune if persisted_objet

          if persisted_objet && row.out_of_scope?
            extend DestroyConcern
          elsif persisted_objet
            extend EdificeConcern
            extend UpdateConcern
          else
            extend EdificeConcern
            extend InsertConcern
          end
        end

        private

        attr_reader :row, :objet_attributes, :persisted_objet, :commune_before_update

        def palissy_REF = objet_attributes[:palissy_REF]

        def all_attributes
          objet_attributes.merge(edifice_attributes)
        end
      end
    end
  end
end
