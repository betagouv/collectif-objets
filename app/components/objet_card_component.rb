# frozen_string_literal: true

class ObjetCardComponent < ViewComponent::Base
  with_collection_parameter :objet

  def initialize(objet:, path: nil, badges: nil, main_photo_url: nil, tags: nil)
    @objet = objet
    @badges = badges
    @path = path
    @main_photo_url = main_photo_url
    @tags = tags
    super
  end

  private

  attr_reader :objet, :badges, :tags

  delegate :nom, :palissy_DENO, :commune, :edifice_nom, :palissy_photos, to: :objet

  def path
    @path ||= objet_path(@objet)
  end

  def truncated_nom
    truncate(nom || palissy_DENO, length: 30)
  end

  def main_photo_url
    @main_photo_url ||= \
      palissy_photos&.first&.fetch("url", nil) \
      || "images/illustrations/photo-manquante.png"
  end
end
