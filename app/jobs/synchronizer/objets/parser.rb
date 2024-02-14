# frozen_string_literal: true

module Synchronizer
  module Objets
    module Parser
      def parse_row_to_objet_attributes(row)
        {
          palissy_REF: row["reference"],
          palissy_COM: row["commune_forme_index"],
          palissy_INSEE: row["cog_insee"]&.split(",")&.first,
          palissy_DPT: row["departement_format_numerique"],
          palissy_DOSS: row["typologie_du_dossier"],
          palissy_EDIF: row["nom_de_l_edifice"],
          palissy_EMPL: row["emplacement_de_l_oeuvre_dans_l_edifice"],
          palissy_TICO: row["titre_editorial"],
          palissy_DPRO: row["date_et_typologie_de_la_protection"],
          palissy_PROT: row["typologie_de_la_protection"],
          palissy_REFA: row["reference_a_une_notice_merimee_mh"]&.match(/PA[A-B0-9]{2}\d{6}/)&.to_s,
          palissy_DENO: row["denomination"],
          palissy_CATE: row["categorie_technique"],
          palissy_SCLE: row["siecle_de_creation"],
          palissy_DENQ: row["date_du_recolement"]
        }
      end
    end
  end
end
