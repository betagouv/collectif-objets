# frozen_string_literal: true

class GalleryComponent < ViewComponent::Base
  MAX_PHOTOS_SHOWN = 4
  PHOTO_STRUCT = Struct.new(:original_url, :thumb_url)

  attr_reader :photos_structs

  delegate :count, to: :photos_structs

  def self.from_attachments(attachments, **kwargs)
    new(attachments.map { PHOTO_STRUCT.new(_1, _1.variant(:medium)) }, **kwargs)
  end

  def self.from_urls(original_urls, **kwargs)
    new(original_urls.map { PHOTO_STRUCT.new(_1, _1) }, **kwargs)
  end

  def initialize(photos_structs, title: nil, responsive_versions: %i[full small])
    @photos_structs = photos_structs
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

  def first_photo_struct
    return photos_structs.first if photos_structs.any?

    PHOTO_STRUCT.new(
      "illustrations/photo-manquante.png",
      "illustrations/photo-manquante.png"
    )
  end

  def last_thumb_open_index
    return 1 if count < MAX_PHOTOS_SHOWN

    5
  end
end
