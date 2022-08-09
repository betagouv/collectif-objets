# frozen_string_literal: true

class PhotosUploadGroupComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :error_message, :existing_photos, :skip_photos_checked

  def initialize(error_message: nil, existing_photos: [], skip_photos_checked: false)
    @error_message = error_message
    @existing_photos = existing_photos
    @skip_photos_checked = skip_photos_checked
    super
  end

  def self.from_form_builder(form_builder)
    new(
      error_message: form_builder.object.errors.messages_for(:photos)&.first,
      existing_photos: form_builder.object.photos,
      skip_photos_checked: form_builder.object.skip_photos
    )
  end
end
