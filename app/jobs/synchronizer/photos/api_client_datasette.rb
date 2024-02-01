# frozen_string_literal: true

module Synchronizer
  module Photos
    class ApiClientDatasette
      PARAMS = { _size: 1000, _shape: "objects", _sort: "REF_PALISSY" }.freeze
      BASE_URL = "https://collectif-objets-datasette.fly.dev/data/palissy_to_memoire.json"
      PER_PAGE = 1000

      def initialize(logger:, limit:)
        @logger = logger
        @limit = limit
        @initial_url = "#{BASE_URL}?#{URI.encode_www_form(PARAMS)}"
      end

      def iterate_batches
        @request_number = 1
        api_query(@initial_url) { yield _1 }
      end

      private

      def api_query(url)
        parsed = fetch_and_parse_url(url)
        create_progress_bar(parsed["filtered_table_rows_count"]) if @request_number == 1
        yield parsed["rows"]
        parsed["rows"].count.times { @progressbar.increment }
        trigger_next_query(parsed) { yield _1 }
      end

      def create_progress_bar(total)
        @logger.info "-- total rows filtered: #{total}"
        total = @limit if @limit.present? && @limit < total
        @progressbar = ProgressBar.create(total:, format: "%t: |%B| %p%% %e")
      end

      def fetch_and_parse_url(url)
        @logger.debug "fetching #{url} ..."
        res = Net::HTTP.get_response(URI.parse(url))
        raise "received #{res.code} on #{url}" unless res.code.starts_with?("2")

        parsed = JSON.parse(res.body)
        @logger.debug "request took #{parsed['query_ms'].round} ms"
        parsed
      end

      def trigger_next_query(parsed)
        return if parsed["next_url"].blank? || limit_reached?

        sleep(0.5)
        @request_number += 1
        api_query(parsed["next_url"]) { yield _1 }
      end

      def limit_reached?
        @limit.present? &&
          @request_number * PER_PAGE >= @limit
      end
    end
  end
end
