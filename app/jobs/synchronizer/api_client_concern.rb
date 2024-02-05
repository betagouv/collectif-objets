# frozen_string_literal: true

module Synchronizer
  module ApiClientConcern
    HOST = "https://collectif-objets-datasette.fly.dev"
    # HOST = "http://localhost:8001"
    PER_PAGE = 1000

    def fetch_and_parse(path, params)
      fetch_and_parse_url(build_url(path, params))
    end

    def build_url(path, params)
      "#{HOST}/#{path}?#{URI.encode_www_form(params)}"
    end

    def fetch_and_parse_url(url)
      @logger&.debug "fetching #{url} ..."
      res = Net::HTTP.get_response(URI.parse(url))
      raise "received #{res.code} on #{url}" unless res.code.starts_with?("2")

      parsed = JSON.parse(res.body)
      @logger&.debug "request took #{parsed['query_ms'].round} ms"
      parsed
    end

    def create_progress_bar(total)
      @logger&.info "-- total rows filtered: #{total}"
      total = @limit if @limit.present? && @limit < total
      @progressbar = ProgressBar.create(total:, format: "%t: |%B| %p%% %e")
    end

    def increment_progress_bar(by)
      @progressbar.progress += by
    end

    def limit_reached?
      @limit.present? &&
        @request_number * PER_PAGE >= @limit
    end
  end
end
