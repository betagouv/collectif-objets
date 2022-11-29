# frozen_string_literal: true

module Synchronizer
  class SynchronizeObjetsPhotosJob
    include Sidekiq::Job

    API_URL = "https://collectif-objets-datasette.fly.dev/data/palissy_to_memoire.json"
    # API_URL = "http://localhost:8001/data/palissy_to_memoire.json"
    BASE_PARAMS = { _size: "1000", _shape: "objects", _sort: "REF_PALISSY" }.freeze

    def perform(params = {})
      @limit = params.with_indifferent_access[:limit]
      @dry_run = params.with_indifferent_access[:dry_run]
      @stack = []
      initial_url = "#{API_URL}?#{URI.encode_www_form(BASE_PARAMS)}"
      ApiClient.new(initial_url, logger:).iterate do |rows|
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
        url: row["URL"],
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
