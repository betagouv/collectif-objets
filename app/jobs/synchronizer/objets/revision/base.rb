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
          if persisted_objet
            @commune_before_update = persisted_objet.commune
            @persisted_objet_snapshot_before_changes = persisted_objet.snapshot_attributes
          end

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
