# frozen_string_literal: true

module Synchronizer
  module ApiMethods
    def iterate_api_requests(url)
      api_query(url, request_number: 1) { yield _1 }
    end

    def api_query(url, request_number:)
      parsed = fetch_and_parse(url)
      logger.info "-- total rows filtered: #{parsed['filtered_table_rows_count']}" if request_number == 1
      yield parsed["rows"]
      trigger_next_query_or_close(parsed, request_number:) { yield _1 }
    end

    def fetch_and_parse(url)
      logger.info "fetching #{url} ..."
      res = Net::HTTP.get_response(URI.parse(url))
      raise "received #{res.code} on #{url}" unless res.code.starts_with?("2")

      parsed = JSON.parse(res.body)
      logger.debug "request took #{parsed['query_ms'].round} ms"
      parsed
    end

    def trigger_next_query_or_close(parsed, request_number:)
      if parsed["next_url"] && (@limit.nil? || request_number * PER_PAGE < @limit)
        sleep(0.5)
        api_query(parsed["next_url"], request_number: request_number + 1) { yield _1 }
      end
      close
    end
  end
end
