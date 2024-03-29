# frozen_string_literal: true

module Synchronizer
  module Communes
    module Parser
      def parse_row_to_commune_and_user_attributes(row)
        code_insee = row["code_insee_commune"]
        {
          commune: {
            code_insee:,
            nom: row["nom"].gsub(/^Mairie - ?/, "").strip,
            phone_number: parse_phone_number(row["telephone"]),
            departement_code: Departement.parse_from_code_insee(code_insee)
          },
          user: {
            email: (row["adresse_courriel"] || "").split(";")[0]
          }
        }
      end

      def parse_phone_number(value)
        return nil if value.blank?

        parsed = JSON.parse(value).first["valeur"]
        return nil if parsed.blank? || parsed == "f"

        parsed
      end
    end
  end
end
