# frozen_string_literal: true

module RecensementWizard
  class Step2 < Base
    STEP_NUMBER = 2
    TITLE = "Précisions sur la localisation"

    def recensement_params = %i[edifice_nom autre_commune_code_insee]

    validates \
      :edifice_nom,
      presence: {
        message: "Veuillez préciser le nom de l’édifice dans lequel l’objet a été déplacé"
      }

    validates :autre_commune_code_insee,
              presence: { message: "Veuillez préciser le code INSEE de la commune dans laquelle l'objet a été déplacé" }
  end
end
