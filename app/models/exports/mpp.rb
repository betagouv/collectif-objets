# frozen_string_literal: true

module Exports
  module Mpp
    module_function

    def to_csv(module_name)
      require "csv"

      CSV.generate(col_sep: ";") do |csv|
        csv << module_name.headers

        module_name.objets.find_each do |objet|
          csv << module_name.values(objet)
        end
      end
    end

    module Deplaces
      module_function

      def objets
        Objet.déplacés.examinés
          .includes(:departement, :commune, :edifice, :recensements)
          .includes(:nouveau_departement, :nouvelle_commune, :nouvel_edifice)
      end

      def headers
        [
          "PM",
          "Département d'origine",
          "Code INSEE d'origine",
          "Nom de la commune d'origine",
          "Édifice d'origine",
          "Département de déplacement",
          "WEB (nouveau code INSEE)",
          "MOSA (nouvel édifice)",
          "Date de validation du dossier par le conservateur",
          "Région de déplacement",
          "Commune de déplacement",
          "DEPL"
        ]
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def values(objet)
        lieu_de_deplacement = [
          objet.nouveau_departement&.region || objet.departement&.region,
          objet.nouveau_departement&.code || objet.departement.code,
          objet.nouvelle_commune&.nom || objet.commune&.nom,
          "#{objet.nouvel_edifice} (Collectif Objets #{objet.recensement.analysed_at.year})"
        ].join(" ; ")
        [
          objet.palissy_REF,
          objet.departement.nom,
          objet.palissy_INSEE,
          objet.commune.nom,
          objet.edifice&.nom&.upcase_first,
          objet.nouveau_departement&.nom,
          objet.lieu_actuel_code_insee,
          objet.nouvel_edifice&.upcase_first,
          I18n.l(objet.recensement.analysed_at, format: :long).upcase_first,
          objet.nouveau_departement&.region || objet.departement.region,
          objet.nouvelle_commune&.nom,
          "Lieu de déplacement : #{lieu_de_deplacement}"
        ]
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def to_csv
        Mpp.to_csv(self)
      end
    end

    module Manquants
      module_function

      def objets
        Objet.manquants.examinés
          .includes(:departement, :commune, :recensements, recensements: :dossier)
      end

      def headers
        [
          "PM",
          "Département d'origine",
          "Code INSEE d'origine",
          "Commentaire de la commune",
          "Commentaire conservateur",
          "Notes",
          "Date de validation par le conservateur",
          "Manquant",
          "Vol"
        ]
      end

      def values(objet)
        [
          objet.palissy_REF,
          objet.departement.nom,
          objet.lieu_actuel_code_insee,
          objet.recensement.dossier.notes_commune,
          objet.recensement.dossier.notes_conservateur,
          objet.recensement.notes,
          I18n.l(objet.recensement.analysed_at, format: :long).upcase_first,
          "Manquant",
          "Œuvre déclarée manquante au moment du recensement Collectif Objets en #{objet.recensement.analysed_at.year}"
        ]
      end

      def to_csv
        Mpp.to_csv(self)
      end
    end
  end
end
