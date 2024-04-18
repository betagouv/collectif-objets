# frozen_string_literal: true

module RecensementWizard
  class Step5 < Base
    STEP_NUMBER = 5
    TITLE = "Objet"

    def recensement_params = %i[etat_sanitaire securisation]

    validates \
      :etat_sanitaire,
      presence: { message: "Veuillez préciser l’état de l’objet" }

    validates \
      :etat_sanitaire,
      inclusion: {
        in: Recensement::ETATS,
        message: "L’état de l’objet n’est pas valide"
      },
      if: -> { etat_sanitaire.present? }

    validates \
      :securisation,
      presence: { message: "Veuillez préciser la sécurisation de l’objet" }

    validates \
      :securisation,
      inclusion: {
        in: Recensement::SECURISATIONS,
        message: "La sécurisation de l’objet n’est pas valide"
      },
      if: -> { securisation.present? }
  end
end
