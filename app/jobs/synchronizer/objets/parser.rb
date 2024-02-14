# frozen_string_literal: true

module Synchronizer
  module Objets
    module Parser
      OBJET_ATTRIBUTES_MAPPING = {
        palissy_REF: "reference",
        palissy_COM: "commune_forme_index",
        palissy_INSEE: "cog_insee",
        palissy_DPT: "departement_format_numerique",
        palissy_DOSS: "typologie_du_dossier",
        palissy_EDIF: "nom_de_l_edifice",
        palissy_EMPL: "emplacement_de_l_oeuvre_dans_l_edifice",
        palissy_TICO: "titre_editorial",
        palissy_DPRO: "date_et_typologie_de_la_protection",
        palissy_PROT: "typologie_de_la_protection",
        palissy_REFA: "reference_a_une_notice_merimee_mh",
        palissy_DENO: "denomination",
        palissy_CATE: "categorie_technique",
        palissy_SCLE: "siecle_de_creation",
        palissy_DENQ: "date_du_recolement"
      }.freeze

      def parse_row_to_objet_attributes(row)
        parsed = OBJET_ATTRIBUTES_MAPPING.transform_values { row[_1] }
        parsed[:palissy_INSEE] = parsed[:palissy_INSEE]&.split(",")&.first
        parsed[:palissy_REFA] = parsed[:palissy_REFA]&.match(/PA[A-B0-9]{2}\d{6}/)&.to_s
        parsed
      end
    end
  end
end
