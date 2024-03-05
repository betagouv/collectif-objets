# frozen_string_literal: true

require "csv"

module Synchronizer
  module Objets
    class ApiClientPalissy
      include ApiClientOpendatasoftConcern

      def initialize
        @host = "data.culture.gouv.fr"
        @dataset_name = "liste-des-objets-mobiliers-propriete-publique-classes-au-titre-des-monuments"
        @csv_filesize_approximate_in_kb = 300_000
      end

      # def find_by_reference(reference)
      #   find_by("reference='#{reference}'")
      # end
    end
  end
end
