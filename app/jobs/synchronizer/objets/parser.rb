# frozen_string_literal: true

module Synchronizer
  module Objets
    module Parser
      def parse_row_to_objet_attributes(row)
        parsed = {
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
          palissy_DENQ: row["date_du_recolement"],
          palissy_DEPL: row["lieu_de_deplacement_de_l_objet"].presence,
          palissy_WEB: row["code_insee_commune_actuelle"].presence,
          palissy_MOSA: row["edifice_actuel"].presence
        }
        parsed.merge(lieu_actuel_attributes(**parsed))
      end

      def lieu_actuel_attributes(palissy_WEB:, palissy_MOSA:, palissy_DEPL:, palissy_INSEE:, palissy_EDIF:,
                                 palissy_REFA:, **_)
        if palissy_WEB.blank?
          # WEB vide : pas de déplacement ni de changement de code INSEE
          {
            lieu_actuel_code_insee: palissy_INSEE,
            lieu_actuel_edifice_nom: palissy_EDIF,
            lieu_actuel_edifice_ref: palissy_REFA
          }
        elsif palissy_DEPL.blank?
          # WEB rempli & DEPL vide = pas de déplacement mais la commune a changé de code INSEE
          {
            lieu_actuel_code_insee: palissy_WEB,
            lieu_actuel_edifice_nom: palissy_EDIF,
            lieu_actuel_edifice_ref: palissy_REFA
          }
        else
          # WEB rempli & DEPL rempli = objet déplacé dans une autre commune
          mosa_splitted = (palissy_MOSA || "").split(";").map(&:strip).map(&:presence)
          {
            lieu_actuel_code_insee: palissy_WEB,
            lieu_actuel_edifice_nom: mosa_splitted[0],
            lieu_actuel_edifice_ref: mosa_splitted[1]
          }
        end
        # NOTE: il n’y a pas besoin de lieu_actuel_empl car EMPL contient déjà l’emplacement actuel
        # même si c’est surprenant par rapport aux autres champs INSEE, EDIF et REFA
      end
    end
  end
end
