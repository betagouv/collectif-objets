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
      recensement.recensable = true if recensement.recensable.nil?
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
    def assign_attributes(permitted_params)
      # Le traitement des photos est différent car géré dans un formulaire et un controller
      # à part (RecensementPhotosController).
      # Photos are handled differently because they are handled in an different form
      # and controller (RecensementPhotosController).
      if permitted_params[:photos]&.any?
        recensement.photos = recensement.photos.map(&:signed_id) + [permitted_params[:photos][0]]
        recensement.photos_count += 1
      else
        super
        if recensable == false && confirmation_not_recensable
          recensement.etat_sanitaire = nil
          recensement.securisation = nil
          recensement.photos = []
          # recensement.photos_count = 0
        elsif recensable == true && recensement.recensable_was == false
          recensement.status = "draft"
        end
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
