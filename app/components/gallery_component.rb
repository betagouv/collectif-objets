# frozen_string_literal: true

class GalleryComponent < ViewComponent::Base
  include ApplicationHelper # for vite_or_raw_image_tag

  MAX_PHOTOS_SHOWN = 4
  PHOTO = Struct.new(:original_url, :thumb_url, :description, keyword_init: true)

  attr_reader :photos, :template

  delegate :count, to: :photos

  def self.from_attachments(attachments, **kwargs)
    new(
      attachments.map do |attachment|
        PHOTO.new(
          Rails.application.routes.url_helpers.url_for(attachment),
          Rails.application.routes.url_helpers.url_for(attachment.variant(:medium)),
          "© Licence ouverte"
        )
      end,
      **kwargs
    )
  end

  def self.palissy_photos_from_objet(objet, **kwargs)
    new(
      objet.palissy_photos.map { PHOTO.new(original_url: _1["url"], thumb_url: _1["url"], description: _1["credit"]) },
      title: I18n.t("objets.palissy_photos_count", count: objet.palissy_photos.count),
      **kwargs
    )
  end

  def initialize(photos, title: nil, template: :full, **options)
    @photos = photos
    @title = title
    @template = template.to_sym
    @options = options.with_indifferent_access
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

  def first_photo
    return photos.first if photos.any?

    PHOTO.new(
      original_url: "images/illustrations/photo-manquante.png",
      thumb_url: "images/illustrations/photo-manquante.png",
      description: "Photo manquante"
    )
  end

  def last_thumb_open_index
    return 1 if count < MAX_PHOTOS_SHOWN

    5
  end

  def json_data
    photos.map { { src: _1.original_url, description: _1.description.presence }.compact }.to_json
  end

  def first_description
    photos.first&.description&.presence
  end

  def display_description?
    @options.fetch(:display_description, false)
  end

  def display_gallery_link?
    @options.fetch(:display_gallery_link, false)
  end
end
