# frozen_string_literal: true

module RecensementWizard
  class Step3 < Base
    STEP_NUMBER = 3
    TITLE = "Photos de l’objet"

    include ActiveStorageValidations

    attr_accessor :confirmation_not_recensable

    validates \
      :recensable,
      inclusion: {
        in: [true, false],
        message: "Veuillez renseigner si l’objet est recensable ou non"
      }

    validates(
      :photos,
      content_type: %w[image/jpg image/jpeg image/png],
      size: { less_than: 20.megabytes }
    )

    def initialize(recensement)
      super
      self.confirmation_not_recensable = recensement.recensable_was == false ? "true" : "false"
    end

    def permitted_params = %i[recensable confirmation_not_recensable photos]

    def confirmation_modal_path_params
      return if recensable != false || confirmation_not_recensable

      { modal: "confirmation-not-recensable",
        wizard: { recensable: "false", confirmation_not_recensable: "true", localisation:, edifice_nom: } }
    end

    def next_step_number
      recensable == false ? 5 : super
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # On n'appelle pas la méthode "super" ici à cause du direct upload des photos
    # We do not call super here due to photo direct uploads
    def assign_attributes(attributes)
      # not sure this is useful considering we do upload photos directly from the client
      if attributes[:photos]&.any?
        recensement.photos = recensement.photos.map(&:signed_id) + [attributes[:photos][0]]
        recensement.photos_count += 1
      end

      if attributes.key?(:confirmation_not_recensable)
        self.confirmation_not_recensable = attributes[:confirmation_not_recensable]
      end
      recensement.assign_attributes(recensable: attributes[:recensable]) if attributes.key?(:recensable)

      if recensable == false && confirmation_not_recensable
        recensement.etat_sanitaire = nil
        recensement.securisation = nil
        recensement.photos = []
      elsif recensable == true && recensement.recensable_was == false
        recensement.status = "draft"
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
