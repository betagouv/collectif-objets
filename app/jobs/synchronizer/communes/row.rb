# frozen_string_literal: true

module Synchronizer
  module Communes
    class Row
      include ActiveModel::Validations

      delegate :[], :key?, to: :@values

      attr_reader :code_insee, :type_service_local, :nom

      def initialize(csv_row)
        @values = csv_row.to_h
        @code_insee = @values["code_insee_commune"].presence
        @type_service_local = parse_type_service_local(@values["pivot"])
        @nom = @values["nom"] || ""
      end

      alias in_scope? valid?
      alias out_of_scope? valid?

      validates :code_insee, presence: true
      validates :type_service_local, inclusion: { in: ["mairie"] }

      validate :validate_mairie_principale

      def validate_mairie_principale
        return true if
          !nom.match(/Mairi(e|é) (déléguée|annexe)/i) &&
          !nom.match(/ - (annexe|antenne) /i) &&
          !nom.match(/bureau annexe/i)

        errors.add(:nom, "n’est pas une mairie principale")
        false
      end

      def parse_type_service_local(value)
        JSON.parse(value || "[]")&.first&.dig("type_service_local")
      rescue JSON::ParserError
        log "error when parsing pivot : #{value} ", counter: :parse_error_pivot
      end
    end
  end
end
