# frozen_string_literal: true

module Synchronizer
  module Communes
    module Batch
      class Base
        include Parser

        def initialize(csv_rows, logger: nil)
          @csv_rows = csv_rows
          @logger = logger
          @eager_load_store = EagerLoadStore.new(self)
          @restrict = restrict
        end

        def revisions
          @revisions ||=
            csv_rows
              .map { Row.new(_1) }
              .select(&:in_scope?)
              .map { parse_row_to_commune_and_user_attributes(_1) }
              .map { { attributes: _1, **eager_loaded_records_for_row(_1) } }
              .select { _1[:objets_count].positive? }
              .map { Revision.new(_1[:attributes], persisted_commune: _1[:commune], logger:) }
        end

        def synchronize(if_block: nil)
          revisions.each do |revision|
            revision.synchronize if if_block.nil? || if_block.call(revision)
            yield if block_given?
          end
        end

        def skipped_rows_count = csv_rows.count - revisions.count

        def unique_code_insees
          @unique_code_insees ||= csv_rows.pluck("code_insee_commune").uniq
        end

        private

        attr_reader :csv_rows, :logger, :eager_load_store, :restrict

        def eager_loaded_records_for_row(row)
          code_insee = row[:commune][:code_insee]
          {
            objets_count: eager_load_store.objets_count_by_code_insee[code_insee],
            commune: eager_load_store.communes_by_code_insee[code_insee]
          }
        end
      end
    end
  end
end
