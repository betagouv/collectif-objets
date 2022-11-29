# frozen_string_literal: true

module Synchronizer
  class ApiClient
    def initialize(url, logger:)
      @url = url
      @logger = logger
    end

    def iterate
      @request_number = 1
      api_query(@url) { yield _1 }
    end

    private

    attr_reader :logger

    def api_query(url)
      parsed = fetch_and_parse(url)
      if @request_number == 1
        @total_rows = parsed["filtered_table_rows_count"]
        logger.info "-- total rows filtered: #{@total_rows}"
        @progressbar = ProgressBar.create(total: @total_rows, format: "%t: |%B| %p%% %e")
      end
      yield parsed["rows"]
      @progressbar.progress += parsed["rows"].count
      trigger_next_query(parsed) { yield _1 }
    end

    def fetch_and_parse(url)
      logger.debug "fetching #{url} ..."
      res = Net::HTTP.get_response(URI.parse(url))
      raise "received #{res.code} on #{url}" unless res.code.starts_with?("2")

      parsed = JSON.parse(res.body)
      logger.debug "request took #{parsed['query_ms'].round} ms"
      parsed
    end

    def trigger_next_query(parsed)
      return if parsed["next_url"].blank? || (@limit.present? && @request_number * PER_PAGE >= @limit)

      sleep(0.5)
      @request_number += 1
      api_query(parsed["next_url"]) { yield _1 }
    end
  end
end
