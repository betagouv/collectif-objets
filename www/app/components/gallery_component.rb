# frozen_string_literal: true

class GalleryComponent < ViewComponent::Base
  attr_reader :photo_urls

  def initialize(photos:, title: nil)
    @photo_urls = photos
    @title = title
    super
  end

  def title
    @title || I18n.t("gallery_component.title", count:)
  end

  delegate :count, to: :photo_urls
end
