# frozen_string_literal: true

module RecensementWizard
  class Step1 < Base
    STEP_NUMBER = 1
    TITLE = "Localisation"

    attr_accessor :confirmation_introuvable

    validates :localisation, presence: { message: "Veuillez préciser où se trouve l’objet" }

    validates :localisation,
              inclusion: {
                in: Recensement::LOCALISATIONS,
                message: "La localisation de l’objet n’est pas valide"
              },
              if: -> { localisation.present? }

    def initialize(recensement)
      super
      self.confirmation_introuvable = recensement.absent? ? "true" : "false"
      # self.localisation = recensement.localisation
    end

    def permitted_params = %i[localisation confirmation_introuvable]

    def next_step_number
      localisation == Recensement::LOCALISATION_ABSENT ? 5 : super
    end

    def confirmation_modal_path_params
      return if localisation != Recensement::LOCALISATION_ABSENT || confirmation_introuvable

      { modal: "confirmation-introuvable",
        wizard: { localisation: Recensement::LOCALISATION_ABSENT, confirmation_introuvable: "true" } }
    end

    def confirmation_modal_close_path
      edit_commune_objet_recensement_path commune, objet, recensement, step: 1
    end

    def assign_attributes(attributes)
      super
      return unless localisation == Recensement::LOCALISATION_ABSENT && confirmation_introuvable

      recensement.localisation = Recensement::LOCALISATION_ABSENT
      recensement.recensable = false
      recensement.edifice_nom = nil
      recensement.etat_sanitaire = nil
      recensement.securisation = nil
      recensement.photos = []
    end
  end
end
