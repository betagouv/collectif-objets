# frozen_string_literal: true

module Synchronizer
  class SynchronizeObjetsPhotosJob
    include Sidekiq::Job

    # API_URL = "https://collectif-objets-datasette.fly.dev/data/palissy.json"
    API_URL = "http://localhost:8001/data/palissy_to_memoire.json"
    BASE_PARAMS = { _size: "1000", _shape: "objects", _sort: "REF_PALISSY" }.freeze

    def perform(params = {})
      @limit = params.with_indifferent_access[:limit]
      @dry_run = params.with_indifferent_access[:dry_run]
      initial_url = "#{API_URL}?#{URI.encode_www_form(BASE_PARAMS)}"
      iterate_api_requests(initial_url) do |rows|
        @stack += rows
        unstack
      end
      update_objet(@stack) if @limit.nil? # last PM
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
      raise unless rows.pluck("REF_PALISSY").to_set.count == 1

      rows.map { format_row(_1) }
    end

    def format_row(row); end

    def synchronize_row(row)
      logger.info "updating objet #{row['REF_PALISSY']} with #{photos.count}"
      objet.save!
    end
  end
end
