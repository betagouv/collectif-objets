# frozen_string_literal: true

module Galerie
  class MiniaturesComponent < ViewComponent::Base
    include ApplicationHelper

    delegate :photos, :title, :count, :actions, to: :@galerie

    MAX_PHOTOS_SHOWN = 4

    def initialize(galerie)
      super
      @galerie = galerie
    end

    def thumbs_count
      return 0 if count <= 1

      [count, MAX_PHOTOS_SHOWN - 1].min
    end

    def hidden_photos_count
      return 0 if count <= MAX_PHOTOS_SHOWN

      count - MAX_PHOTOS_SHOWN
    end

    def credits = photos.map(&:credit).uniq
  end
end
