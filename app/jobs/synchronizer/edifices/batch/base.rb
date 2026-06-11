# frozen_string_literal: true

module Synchronizer
  module Edifices
    module Batch
      class Base
        include Parser

        def initialize(csv_rows, logger: nil)
          @csv_rows = csv_rows
          @logger = logger
        end

        def revisions
          @revisions ||=
            csv_rows
              .map { parse_row_to_edifice_attributes(it) }
              .map { Revision.new(it, logger:) }
        end

        def synchronize
          revisions.each do |revision|
            revision.synchronize
            yield if block_given?
          end
        end

        private

        attr_reader :csv_rows, :logger
      end
    end
  end
end
