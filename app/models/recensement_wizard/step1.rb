# frozen_string_literal: true

module RecensementWizard
  class Step1 < Base
    TITLE = "Localisation"

    attr_accessor :confirmation_introuvable

    validates :localisation, presence: { message: "Veuillez préciser où se trouve l’objet" }

    validates :localisation,
              inclusion: {
                in: Recensement::LOCALISATIONS,
                message: "La localisation de l’objet n’est pas valide"
              },
              if: -> { localisation.present? }

    def setup_step
      self.confirmation_introuvable = recensement.absent? ? "true" : "false"
    end

    def permitted_params = %i[localisation confirmation_introuvable]

    def next_step_number
      if localisation == Recensement::LOCALISATION_ABSENT ||
         localisation == Recensement::LOCALISATION_DEPLACEMENT_TEMPORAIRE
        6
      elsif localisation == Recensement::LOCALISATION_EDIFICE_INITIAL
        3
      else
        super
      end
    end

    def confirmation_modal_path_params
      return if localisation != Recensement::LOCALISATION_ABSENT || confirmation_introuvable

      { modal: "confirmation-introuvable",
        wizard: { localisation: Recensement::LOCALISATION_ABSENT, confirmation_introuvable: "true" } }
    end

    def reset_recensement_data_for_next_steps
      return unless recensement.localisation_changed?

      recensement.edifice_nom = nil
      recensement.autre_commune_code_insee = nil
    end
  end
end
