# frozen_string_literal: true

module Galerie
  class LightboxComponent < ViewComponent::Base
    include ApplicationHelper

    attr_reader :parent_galerie

    delegate(
      :photos, :current_photo_id, :display_actions, :close_path, :turbo_frame, :lightbox_photo_path,
      :count, to: :parent_galerie
    )

    def initialize(parent_galerie)
      super
      @parent_galerie = parent_galerie
    end

    def current_index
      photos.find_index { _1.id == current_photo_id.to_i }
    end

    def current_photo
      photos[current_index]
    end

    def previous_photo_path
      return if current_index <= 0

      lightbox_photo_path(photos[current_index - 1].id)
    end

    def next_photo_path
      return unless current_index + 1 < count

      lightbox_photo_path(photos[current_index + 1].id)
    end
  end
end
