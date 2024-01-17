# frozen_string_literal: true

require "csv"

module Synchronizer
  module ApiClientOpendatasoftConcern
    extend ActiveSupport::Concern

    def lazy_iterator
      first_line = File.open(csv_path, &:gets)
      headers = first_line.split(";").map(&:downcase)
      CSV.foreach(csv_path, headers:, col_sep: ";").lazy.drop(1)
      # drop first line because we explicitly pass the headers
    end

    delegate :each, :each_slice, to: :lazy_iterator

    def count_all
      @count_all ||= begin
        Rails.logger.info "counting all rows in #{csv_path} ..."
        CSV.foreach(csv_path, headers: true, col_sep: ";").count
      end
    end

    def find_by(where)
      url = "#{base_url}/records?#{{ where: }.to_query}"
      response = JSON.parse(Net::HTTP.get(URI(url)))

      raise "API error: #{response['error_code']} #{response['message']}" if response["error_code"]

      return nil if response["total_count"].zero?

      raise "too many results" if response["total_count"] > 1

      response["results"].first
    end

    private

    def csv_path
      # useful to iterate, make sure to download the csv with ?with_bom=false
      return ENV["USE_LOCAL_FILE"] if ENV["USE_LOCAL_FILE"].present?

      @csv_path ||= begin
        download_csv_to_temp_file
        @temp_file.path
      end
    end

    def base_url
      "https://#{@host}/api/explore/v2.1/catalog/datasets/#{@dataset_name}/"
    end

    def csv_url = "#{base_url}/exports/csv"

    def download_csv_to_temp_file
      progressbar = ProgressBar.create(total: @csv_filesize_approximate_in_kb, format: "%t: |%B| %p%% %e (%c kb/%u)")
      # this needs to be an instance var so it is not garbage collected too early
      @temp_file = Tempfile.new(["opendatasoft_export_#{@dataset_name}", ".csv"], binmode: true)
      Rails.logger.info "downloading #{csv_url} ..."
      request = Typhoeus::Request.new(csv_url, params: { use_labels: "true", delimiter: ";", with_bom: "false" })
      request.on_headers do |response|
        raise "Request failed with #{response.code}" if response.code != 200
      end
      request.on_body do |chunk|
        (chunk.size / 1024).floor.times { progressbar.increment }
        @temp_file.write(chunk)
      end
      request.on_complete do |_response|
        progressbar.finish
        @temp_file.close
      end
      request.run

      @temp_file.path
    end
  end
end
