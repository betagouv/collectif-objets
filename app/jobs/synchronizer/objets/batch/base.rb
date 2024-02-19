# frozen_string_literal: true

module Synchronizer
  module Objets
    module Batch
      class Base
        include Parser
        include LogConcern

        def initialize(csv_rows, logger: nil)
          @csv_rows = csv_rows
          @logger = logger
          @eager_load_store = EagerLoadStore.new(self)
        end

        def all_rows
          @all_rows ||= @csv_rows.map { Row.new(_1) }
        end

        def all_objets_attributes
          @all_objets_attributes ||= all_rows.map(&:objet_attributes)
        end

        def all_eager_loaded_records
          @all_eager_loaded_records ||= all_objets_attributes.map { EagerLoadedRecords.new(_1, @eager_load_store) }
        end

        def revisions
          @revisions ||=
            all_objets_attributes
              .zip(all_eager_loaded_records)
              .map do |objet_attributes, eager_loaded_records|
                Revision.new(objet_attributes, eager_loaded_records:, logger:)
              end
        end

        def synchronize_each_revision
          revisions.each do |revision|
            success = revision.synchronize
            @eager_load_store.add_edifice(revision.objet.edifice) if success && revision.new_edifice?
            yield(revision) if block_given?
          end
        end

        def skipped_rows_count = @csv_rows.count - revisions.count

        def unique_palissy_REFs = @csv_rows.pluck("reference").uniq
        def unique_code_insees = all_objets_attributes.pluck(:lieu_actuel_code_insee).compact.uniq
      end
    end
  end
end
