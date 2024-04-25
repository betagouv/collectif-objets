# frozen_string_literal: true

module RecensementWizard
  class Step2 < Base
    STEP_NUMBER = 2
    TITLE = "Précisions sur la localisation"

    attr_accessor :edifice_nom_existant, :autre_edifice_checked, :autre_commune_code_insee

    validates :edifice_nom_existant,
              presence: { message: "Veuillez sélectionner un édifice. \
                S’il n'est pas dans la liste, choisir \"Autre édificie\"." },
              unless: -> { autre_edifice_checked }

    validates \
      :edifice_nom,
      presence: {
        message: "Veuillez préciser le nom de l’édifice dans lequel l’objet a été déplacé"
      }, if: -> { autre_edifice_checked }

    def permitted_params = %i[edifice_nom_existant edifice_nom autre_edifice_checked autre_commune_code_insee]

    def initialize(recensement)
      super
      self.autre_edifice_checked = recensement.edifice_nom.present? &&
                                   recensement.commune.edifices.pluck(:nom).exclude?(recensement.edifice_nom)
      self.autre_commune_code_insee ||= recensement.commune.code_insee
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

      # if autre_edifice_checked
      #   recensement.edifice_id = nil
      # else
      #   recensement.edifice_nom = nil
      # end
    end
  end
end
