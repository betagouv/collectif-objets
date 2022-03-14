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

  def photos_imgs(limit: 100)
    return nil if photos.empty?

    photos[0..limit].map do |photo|
      "<img src=\"#{url_for(photo)}\" style=\"max-width: 150px; max-height: 150px;\" />".html_safe
    end
  end
end
