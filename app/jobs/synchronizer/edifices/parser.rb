# frozen_string_literal: true

module Synchronizer
  module Edifices
    module Parser
      def parse_row_to_edifice_attributes(row)
        # code_insee = row["code_insee_commune"]
        {
          merimee_REF: row["reference"],
          nom: row["titre_editorial_de_la_notice"],
          slug: Edifice.slug_for(row["titre_editorial_de_la_notice"]),
          code_insee: parse_code_insee(row["cog_insee_lors_de_la_protection"])
        }
      end

      def parse_code_insee(value)
        if value.is_a?(String)
          value.split(",")[0] # when from CSV
        elsif value.is_a?(Array)
          value[0] # when from API
        end
      end
    end
  end
end
