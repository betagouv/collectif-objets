# frozen_string_literal: true

module Synchronizer
  module Objets
    module Batch
      class Base
        include Parser

        attr_reader :logfile

        def initialize(csv_rows, logfile: nil)
          @csv_rows = csv_rows
          @logfile = logfile
          @eager_load_store = EagerLoadStore.new(self)
        end

        def all_objets_attributes
          @all_objets_attributes ||=
            @csv_rows
              .map { Row.new(_1) }
              .filter(&:in_scope?)
              .map { parse_row_to_objet_attributes(_1) }
        end

        def all_objets_attributes_with_eager_loaded_records
          @all_objets_attributes_with_eager_loaded_records ||=
            all_objets_attributes
              .map { [_1, EagerLoadedRecords.new(_1, @eager_load_store)] }
              .select { |_objet_attributes, eager_loaded_records| eager_loaded_records.commune.present? }
          # TODO: we should rather create the commune
        end

        def revisions
          @revisions ||=
            all_objets_attributes_with_eager_loaded_records
              .map do |objet_attributes, eager_loaded_records|
              Revision.new(objet_attributes, eager_loaded_records:, logfile:)
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
        def unique_code_insees = all_objets_attributes.pluck(:palissy_INSEE).uniq
      end
    end
  end
end
