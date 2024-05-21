# frozen_string_literal: true

module RecensementWizard
  class Step2 < Base
    TITLE = "Précisions sur la localisation"

    attr_accessor :edifice_nom_existant, :autre_edifice_checked

    validates :edifice_nom_existant,
              presence: { message: "Veuillez sélectionner un édifice. \
                S’il n'est pas dans la liste, choisir \"Autre édifice\"." },
              unless: lambda {
                localisation != Recensement::LOCALISATION_AUTRE_EDIFICE ||
                  (localisation == Recensement::LOCALISATION_DEPLACEMENT_AUTRE_COMMUNE && autre_edifice_checked)
              }

    validates \
      :edifice_nom,
      presence: {
        message: "Veuillez préciser le nom de l’édifice dans lequel l’objet a été déplacé"
      }, if: lambda {
        localisation == Recensement::LOCALISATION_DEPLACEMENT_AUTRE_COMMUNE ||
          (localisation == Recensement::LOCALISATION_AUTRE_EDIFICE && autre_edifice_checked)
      }

    validates :autre_commune_code_insee,
              presence: { message: "Le code INSEE dans lequel se trouve maintenant l’objet doit être indiqué" },
              if: -> { localisation == Recensement::LOCALISATION_DEPLACEMENT_AUTRE_COMMUNE }

    def permitted_params = %i[edifice_nom_existant edifice_nom autre_edifice_checked autre_commune_code_insee]

    def initialize(recensement)
      super
      self.autre_edifice_checked = recensement.edifice_nom.present? &&
                                   recensement.commune.edifices.pluck(:nom).exclude?(recensement.edifice_nom)
    end

    def assign_attributes(attributes)
      if attributes[:edifice_nom_existant].present? && attributes[:edifice_nom_existant] == "0"
        attributes[:autre_edifice_checked] = true
      end

      if attributes[:edifice_nom_existant].present? && attributes[:edifice_nom_existant] != "0"
        attributes[:autre_edifice_checked] = false
        attributes[:edifice_nom] = attributes[:edifice_nom_existant]
      end

      super
    end

    def next_step_number
      localisation == Recensement::LOCALISATION_DEPLACEMENT_AUTRE_COMMUNE ? 6 : super
    end
  end
end
