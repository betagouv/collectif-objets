# frozen_string_literal: true

require "csv"

module Synchronizer
  class ApiClientMerimee
    include ApiClientOpendatasoftConcern

    def initialize
      @host = "data.culture.gouv.fr"
      @dataset_name = "liste-des-immeubles-proteges-au-titre-des-monuments-historiques"
      @csv_filesize_approximate_in_kb = 238_000
    end

    def find_by_reference(reference)
      find_by("reference='#{reference}'")
    end
  end
end
