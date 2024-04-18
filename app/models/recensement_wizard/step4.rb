# frozen_string_literal: true

module RecensementWizard
  class Step4 < Base
    STEP_NUMBER = 4
    TITLE = "Photos de l’objet"

    include ActiveStorageValidations

    attr_accessor :confirmation_no_photos

    delegate :photos, :photo_attachments, to: :recensement

    def recensement_params = %i[photos]

    def wizard_params = %i[confirmation_no_photos]

    validates(
      :photos,
      content_type: %w[image/jpg image/jpeg image/png],
      size: { less_than: 20.megabytes }
    )

    def initialize(recensement)
      super
      self.confirmation_no_photos = "false"
    end

    # rubocop:disable Style/GuardClause
    def assign_attributes(parsed_params)
      if parsed_params[:photos]&.any?
        recensement.photos = recensement.photos.map(&:signed_id) + [parsed_params[:photos][0]]
        recensement.photos_count += 1
      end
      if parsed_params.key?(:confirmation_no_photos)
        self.confirmation_no_photos = parsed_params[:confirmation_no_photos]
      end
    end
    # rubocop:enable Style/GuardClause

    def confirmation_modal_path_params
      return if photos.any? || confirmation_no_photos

      { modal: "confirmation-no-photos", wizard: { confirmation_no_photos: "true" } }
    end
  end
end
