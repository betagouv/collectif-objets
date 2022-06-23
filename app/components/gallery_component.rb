# frozen_string_literal: true

class GalleryComponent < ViewComponent::Base
  attr_reader :photo_urls

  MAX_PHOTOS_SHOWN = 4

  def initialize(photos:, title: nil, responsive_versions: %i[full small])
    @photo_urls = photos
    @title = title
    @responsive_versions = responsive_versions
    super
  end

  def title
    @title || I18n.t("gallery_component.title", count:)
  end

  def thumbs_count
    return 0 if count <= 1

    [count, MAX_PHOTOS_SHOWN - 1].min
  end

  def hidden_photos_count
    return 0 if count <= MAX_PHOTOS_SHOWN

    count - MAX_PHOTOS_SHOWN
  end

  def responsive_version_full?
    @responsive_versions.include?(:full)
  end

  def responsive_version_small?
    @responsive_versions.include?(:small)
  end

  def first_photo_url
    return photo_urls.first if photo_urls.any?

    "illustrations/photo-manquante.png"
  end

  def last_thumb_open_index
    return 1 if count < MAX_PHOTOS_SHOWN

    5
  end

  delegate :count, to: :photo_urls
end
