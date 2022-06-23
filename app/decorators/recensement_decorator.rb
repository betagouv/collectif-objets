# frozen_string_literal: true

class RecensementDecorator < Draper::Decorator
  include ActionView::Helpers
  include Rails.application.routes.url_helpers
  delegate_all

  def display_name
    "Recensement ##{id}"
  end

  def objet
    super.decorate
  end

  def commune
    objet.commune&.decorate
  end

  def notes_truncated
    truncate(notes, length: 30)
  end

  def first_photo_img
    photos_imgs(limit: 1)
  end

  # rubocop:disable Rails/OutputSafety
  def photos_imgs(limit: 100)
    return '<span class="status_tag warning">manquantes</span>'.html_safe if missing_photos?

    return nil if photos.empty?

    photos[0..limit].map do |photo|
      "<img src=\"#{url_for(photo)}\" style=\"max-width: 150px; max-height: 150px;\" />".html_safe
    end
  end
  # rubocop:enable Rails/OutputSafety
end
