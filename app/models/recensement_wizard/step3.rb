# frozen_string_literal: true

module RecensementWizard
  class Step3 < Base
    STEP_NUMBER = 3
    TITLE = "Localisation"

    attr_accessor :confirmation_not_recensable

    validates \
      :localisation,
      presence: { message: "Veuillez préciser où se trouve l’objet" }

    validates \
      :localisation,
      inclusion: {
        in: [Recensement::LOCALISATION_EDIFICE_INITIAL, Recensement::LOCALISATION_AUTRE_EDIFICE],
        message: "La localisation de l’objet n’est pas valide"
      },
      if: -> { localisation.present? }

    validates \
      :edifice_nom,
      presence: {
        message: "Veuillez préciser le nom de l’édifice dans lequel l’objet a été déplacé"
      },
      if: -> { localisation == Recensement::LOCALISATION_AUTRE_EDIFICE }

    validates \
      :recensable,
      inclusion: {
        in: [true, false],
        message: "Veuillez renseigner si l’objet est recensable ou non"
      }

    def initialize(recensement)
      super
      self.confirmation_not_recensable = recensement.recensable_was == false ? "true" : "false"
    end

    def permitted_params = %i[localisation edifice_nom recensable confirmation_not_recensable]

    def confirmation_modal_path_params
      return if recensable != false || confirmation_not_recensable

      { modal: "confirmation-not-recensable",
        wizard: { recensable: "false", confirmation_not_recensable: "true", localisation:, edifice_nom: } }
    end

    def next_step_number
      recensable == false ? 6 : super
    end

    def assign_attributes(attributes)
      super
      if recensable == false && confirmation_not_recensable
        recensement.etat_sanitaire = nil
        recensement.securisation = nil
        recensement.photos = []
      elsif recensable == true && recensement.recensable_was == false
        recensement.status = "draft"
      end
    end
  end
end
