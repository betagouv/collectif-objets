# frozen_string_literal: true

class GalleryComponent < ViewComponent::Base
  attr_reader :photo_urls

  MAX_PHOTOS_SHOWN = 4

  def initialize(photos:, title: nil)
    @photo_urls = photos
    @title = title
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

  delegate :count, to: :photo_urls
end
