# frozen_string_literal: true

module Synchronizer
  module Objets
    class Row
      include ActiveModel::Validations

      delegate :[], :key?, to: :@values

      attr_reader :cog_insee, :typologie_du_dossier, :statut_juridique_de_l_objet,
                  :statut_juridique_du_proprietaire, :titre_editorial, :date_et_typologie_de_la_protection

      def initialize(csv_row)
        @values = csv_row.to_h
        @cog_insee = @values["cog_insee"] || ""
        @typologie_du_dossier = @values["typologie_du_dossier"] || ""
        @statut_juridique_de_l_objet = @values["statut_juridique_de_l_objet"] || ""
        @statut_juridique_du_proprietaire = @values["statut_juridique_du_proprietaire"] || ""
        @titre_editorial = @values["titre_editorial"] || ""
        @date_et_typologie_de_la_protection = @values["date_et_typologie_de_la_protection"] || ""
      end

      alias in_scope? valid?
      alias out_of_scope? invalid?
      def out_of_scope_message = errors.map(&:message).to_sentence

      validates :cog_insee, presence: { message: "la notice n’a pas de code INSEE" }

      validates \
        :typologie_du_dossier,
        inclusion: {
          in: [
            "dossier individuel",
            "dossier avec sous-dossier",
            "individuel",
            "dossier indiviuel",
            "dossier avec sous-dossiers"
          ],
          allow_blank: false,
          message: "la notice ne correspond pas à un dossier individuel"
        }

      validates \
        :statut_juridique_de_l_objet,
        exclusion: {
          in: %W[manquant vol\u00E9],
          message: "l’objet est manquant ou volé"
        }

      validates \
        :titre_editorial,
        exclusion: {
          in: ["Traitement en cours"],
          message: "la notice est en cours de traitement"
        }

      validate :validate_statut_juridique_du_proprietaire, :validate_date_et_typologie_de_la_protection

      def validate_statut_juridique_du_proprietaire
        out_of_scope_propriete = statut_juridique_du_proprietaire
          .split(";")
          .intersection(["propriété de l'Etat", "propriété de l'Etat (?)"])
          .first

        return if out_of_scope_propriete.nil?

        errors.add(:statut_juridique_du_proprietaire, "l’objet est propriété de l’État")
      end

      def validate_date_et_typologie_de_la_protection
        most_recent_typologie = date_et_typologie_de_la_protection.split(";").last || ""
        return if most_recent_typologie.exclude?("déclassé")

        errors.add(:date_et_typologie_de_la_protection, "l’objet est déclassé")
      end
    end
  end
end
