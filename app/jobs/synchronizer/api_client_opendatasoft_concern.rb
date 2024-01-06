# frozen_string_literal: true

require "csv"

module Synchronizer
  module ApiClientOpendatasoftConcern
    extend ActiveSupport::Concern

    included do
      def self.all(&)
        new.all(&)
      end

      def self.find_by(where)
        url = "#{base_url}/records?#{{ where: }.to_query}"
        response = JSON.parse(Net::HTTP.get(URI(url)))

        raise "API error: #{response['error_code']} #{response['message']}" if response["error_code"]

        return nil if response["total_count"].zero?

        raise "too many results" if response["total_count"] > 1

        response["results"].first
      end
    end

    def lazy_iterator
      download_csv_file_if_first_call
      first_line = File.open(@csv_path, &:gets)
      headers = first_line.split(";").map(&:downcase)
      CSV.foreach(@csv_path, headers:, col_sep: ";").lazy.drop(1)
      # drop first line because we explicitly pass the headers
    end

    delegate :each, :each_slice, to: :lazy_iterator

    def count_all
      @count_all ||= begin
        download_csv_file_if_first_call
        Rails.logger.info "counting all rows in #{@csv_path} ..."
        CSV.foreach(@csv_path, headers: true, col_sep: ";").count
      end
    end

    def download_csv_file_if_first_call
      return if @csv_path.present?

      if ENV["USE_LOCAL_FILE"]
        @csv_path = ENV["USE_LOCAL_FILE"]
        Rails.logger.info "using local file #{@csv_path}}"
        return
      end

      temp_file = download("#{base_url}/exports/csv?use_labels=true&delimiter=;&with_bom=false")
      @csv_path = temp_file.path
    end

    private

    def base_url
      "https://#{@host}/api/explore/v2.1/catalog/datasets/#{@dataset_name}/"
    end

    def download(url)
      temp_file = Tempfile.new(["opendatasoft_export_#{@dataset_name}", ".csv"])

      `curl -o #{temp_file.path} "#{url}"` # TODO: is this okay for prod ?

      temp_file
    end
  end
end
