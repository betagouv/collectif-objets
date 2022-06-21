# frozen_string_literal: true

class ObjetDecorator < Draper::Decorator
  include ActionView::Helpers
  delegate_all

  def display_name
    "#{palissy_REF} · #{truncate(nom, length: 30)}"
  end

  def commune
    super&.decorate
  end

  # rubocop:disable Rails/OutputSafety
  def image_urls
    return nil if super&.empty?

    "<img src=\"#{super.first}\" style=\"max-width: 150px; max-height: 150px;\" />".html_safe
  end
  # rubocop:enable Rails/OutputSafety
end
