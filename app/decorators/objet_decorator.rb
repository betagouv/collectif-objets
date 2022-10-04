# frozen_string_literal: true

class ObjetDecorator < Draper::Decorator
  include ActionView::Helpers
  delegate_all

  delegate :count, to: :palissy_photos, prefix: true

  def palissy_photos_img
    image_tag = palissy_photos.any? &&
                image_tag(palissy_photos.first["url"], style: "max-width: 150px; max-height: 150px;")
    if palissy_photos_count == 1
      image_tag
    elsif palissy_photos_count > 1
      image_tag + content_tag(:div, "+ #{palissy_photos_count - 1} autres photo(s)")
    elsif palissy_photos_count.zero?
      "<i>aucune photo</i>".html_safe
    end
  end

  def display_name
    "#{palissy_REF} · #{truncate(nom, length: 30)}"
  end

  def commune
    super&.decorate
  end
end
