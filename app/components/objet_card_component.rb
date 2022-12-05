# frozen_string_literal: true

class ObjetCardComponent < ViewComponent::Base
  with_collection_parameter :objet

  def initialize(objet = nil, **kwargs)
    @objet = objet || kwargs[:objet]
    @badges = kwargs[:badges]
    @path = kwargs[:path]
    @main_photo_url = kwargs[:main_photo_url]
    @tags = kwargs[:tags]
    @commune = kwargs[:commune] || @objet.commune # pass to avoid n+1 queries
    super
  end

  private

  attr_reader :objet, :badges, :tags, :commune

  delegate :nom, :palissy_DENO, :edifice_nom, :palissy_photos, to: :objet

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
