# frozen_string_literal: true

module Synchronizer
  module Photos
    class SynchronizeAllJob < ApplicationJob
      MEMOIRE_PHOTOS_BASE_URL = "https://s3.eu-west-3.amazonaws.com/pop-phototeque"

      def perform(params = {})
        @limit = params.with_indifferent_access[:limit]
        @dry_run = params.with_indifferent_access[:dry_run]
        @stack = []
        ApiClientJson
          .objets_photos(params: { _sort: "REF_PALISSY" }, logger:, limit: @limit)
          .iterate_batches do |rows|
            @stack += rows
            unstack
          end
        update_objet(@stack) if @limit.nil? && @stack.count >= 1 # last PM
      end

      private

      # groups rows in the stack by PALISSY REFs & use them to update objets
      def unstack
        while @stack.count >= 1 && @stack.first["REF_PALISSY"] != @stack.last["REF_PALISSY"]
          update_objet(
            @stack.shift(
              @stack.index { _1["REF_PALISSY"] != @stack.first["REF_PALISSY"] }
            )
          )
        end
      end

      def update_objet(rows)
        palissy_refs = rows.pluck("REF_PALISSY").to_set
        raise unless palissy_refs.count == 1

        palissy_photos = rows.map { format_row(_1) }
        Objet.where(palissy_REF: palissy_refs.first).limit(1).update_all(palissy_photos:)
      end

      def format_row(row)
        {
          url: [MEMOIRE_PHOTOS_BASE_URL, row["URL"]].join("/"),
          name: row["NAME"],
          credit: row["COPY"]
        }
      end

      def synchronize_row(row)
        logger.info "updating objet #{row['REF_PALISSY']} with #{photos.count}"
        objet.save!
      end
    end
  end
end
