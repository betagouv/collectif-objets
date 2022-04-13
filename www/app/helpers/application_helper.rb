# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def head_title
    if content_for(:head_title).present?
      "#{content_for(:head_title)} · Collectif Objets"
    else
      "Collectif Objets"
    end
  end
end
