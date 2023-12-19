# frozen_string_literal: true

module Galerie
  class LightboxComponent < ViewComponent::Base
    include ApplicationHelper

    attr_reader :parent_galerie

    delegate(
      :photos, :current_photo_id, :display_actions, :close_path, :turbo_frame, :count,
      :path_without_query, to: :parent_galerie
    )

    def initialize(parent_galerie)
      super
      @parent_galerie = parent_galerie
    end

    def current_index
      photos.find_index { _1.id == current_photo_id.to_i }
    end

    def current_photo = photos[current_index]

    def previous_photo
      photos[current_index - 1] if current_index.positive?
    end

    def next_photo
      photos[current_index + 1] if current_index + 1 < count
    end
  end
end
