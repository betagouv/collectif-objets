# frozen_string_literal: true

class ObjetCardComponent < ViewComponent::Base
  using HTMLAttributesUtils

  with_collection_parameter :objet

  def initialize(objet = nil, **kwargs)
    @objet = objet || kwargs[:objet]
    @header_badges = kwargs[:header_badges]
    @start_badges = kwargs[:start_badges]
    @path = kwargs[:path]
    @main_photo = kwargs[:main_photo]
    @tags = kwargs[:tags]
    @commune = kwargs[:commune] || @objet.commune # pass to avoid n+1 queries
    @main_photo_origin = kwargs[:main_photo_origin] || :memoire
    @link_html_attributes_custom = kwargs[:link_html_attributes] || {}
    @recensement = kwargs[:recensement] || @objet.current_recensement
    super
  end

  private

  attr_reader :objet, :header_badges, :start_badges, :tags, :commune, :recensement, :main_photo_origin

  delegate :nom, :palissy_DENO, :edifice_nom, :palissy_photos, to: :objet

  def path
    @path ||= objet_path(@objet)
  end

  def truncated_nom
    truncate(nom || palissy_DENO, length: 30)
  end

  def main_photo
    return @main_photo if @main_photo.present?

    {
      memoire: main_photo_palissy,
      recensement: main_photo_recensement,
      recensement_or_memoire: main_photo_recensement || main_photo_palissy
    }[main_photo_origin]
  end

  def link_html_attributes
    { class: "fr-card__link" }
      .deep_merge_html_attributes(@link_html_attributes_custom)
      .deep_tidy_html_attributes
  end

  def main_photo_palissy = palissy_photos&.first

  def main_photo_recensement
    return unless recensement&.photos&.any?

    Photo.new \
      url: recensement.photos.first.variant(:medium),
      description: "Photo de recensement de l’objet #{objet.nom}"
  end
end
