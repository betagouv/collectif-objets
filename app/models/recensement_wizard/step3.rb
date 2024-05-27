# frozen_string_literal: true

module RecensementWizard
  class Step3 < Base
    TITLE = "Accessibilité"

    include ActiveStorageValidations

    attr_accessor :confirmation_not_recensable

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

    def permitted_params = %i[recensable confirmation_not_recensable]

    def confirmation_modal_path_params
      return if recensable != false || confirmation_not_recensable

      { modal: "confirmation-not-recensable",
        wizard: { recensable: "false", confirmation_not_recensable: "true" } }
    end

    def next_step_number
      recensable == false ? 6 : super
    end
  end
end
