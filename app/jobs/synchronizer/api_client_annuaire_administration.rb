# frozen_string_literal: true

module Synchronizer
  class ApiClientAnnuaireAdministration
    include ApiClientOpendatasoftConcern

    def initialize
      @host = "api-lannuaire.service-public.fr"
      @dataset_name = "api-lannuaire-administration"
      @csv_filesize_approximate_in_kb = 120_000
    end
  end
end
