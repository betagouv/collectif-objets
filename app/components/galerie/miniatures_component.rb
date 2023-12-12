# frozen_string_literal: true

module Galerie
  class MiniaturesComponent < ViewComponent::Base
    include ApplicationHelper

    attr_reader :parent_galerie

    delegate :photos, :title, :lightbox_photo_path, :count, to: :parent_galerie

    MAX_PHOTOS_SHOWN = 4

    def initialize(parent_galerie)
      super
      @parent_galerie = parent_galerie
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

    def texte_lien_titre = count > 1 ? "Voir la galerie" : "Agrandir"
  end
end
