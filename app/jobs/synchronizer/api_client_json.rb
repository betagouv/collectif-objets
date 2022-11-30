# frozen_string_literal: true

module Synchronizer
  class ApiClientJson
    include ApiClientConcern

    BASE_PARAMS = { _size: 1000, _shape: "objects" }.freeze

    def self.objets_photos(params: nil, **kwargs)
      new("data/palissy_to_memoire.json", BASE_PARAMS.merge(params), **kwargs)
    end

    def self.edifices(params: nil, **kwargs)
      new("data/merimee.json", BASE_PARAMS.merge(params), **kwargs)
    end

    def initialize(path, params, logger:, limit:)
      @path = path
      @params = params
      @logger = logger
      @limit = limit
    end

    def iterate_batches
      @request_number = 1
      api_query(build_url(@path, @params)) { yield _1 }
    end

    def iterate
      iterate_batches { |batch| batch.each { yield _1 } }
    end

    def first
      @request_number = 1
      parsed = fetch_and_parse_url(build_url(@path, @params))
      return parsed["rows"][0] if parsed["rows"].count >= 1
    end

    private

    def api_query(url)
      parsed = fetch_and_parse_url(url)
      create_progress_bar(parsed["filtered_table_rows_count"]) if @request_number == 1
      yield parsed["rows"]
      increment_progress_bar parsed["rows"].count
      trigger_next_query(parsed) { yield _1 }
    end

    def trigger_next_query(parsed)
      return if parsed["next_url"].blank? || limit_reached?

      sleep(0.5)
      @request_number += 1
      api_query(parsed["next_url"]) { yield _1 }
    end
  end
end
