# frozen_string_literal: true

module RecensementWizard
  class Step1 < Base
    STEP_NUMBER = 1
    TITLE = "Recherche"

    attr_accessor :investigation, :confirmation_introuvable

    validates :investigation,
              inclusion: { in: %w[confirmation_sur_place introuvable],
                           message: "Veuillez choisir une option parmi les 3" }

    def initialize(recensement)
      super
      self.confirmation_introuvable = recensement.absent? ? "true" : "false"
      if recensement.absent?
        self.investigation = "introuvable"
      elsif recensement.confirmation_sur_place?
        self.investigation = "confirmation_sur_place"
      end
    end

    def permitted_params = %i[investigation confirmation_introuvable]

    def next_step_number
      investigation == "introuvable" ? 5 : super
    end

    def confirmation_modal_path_params
      return if investigation != "introuvable" || confirmation_introuvable

      { modal: "confirmation-introuvable",
        wizard: { investigation: "introuvable", confirmation_introuvable: "true" } }
    end

    def assign_attributes(attributes)
      super
      if investigation == "confirmation_sur_place"
        recensement.confirmation_sur_place = true
        if recensement.absent?
          recensement.recensable = nil
          recensement.localisation = nil
          recensement.status = "draft" # force returning to draft for completed ones
        end
      elsif investigation == "introuvable" && confirmation_introuvable
        recensement.confirmation_sur_place = true
        recensement.localisation = Recensement::LOCALISATION_ABSENT
        recensement.recensable = false
        recensement.edifice_nom = nil
        recensement.etat_sanitaire = nil
        recensement.securisation = nil
        recensement.photos = []
      end
    end
  end
end
