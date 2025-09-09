# frozen_string_literal: true

class ObjetCardComponent < ApplicationComponent
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
    @recensement = kwargs[:recensement] || @objet.recensement
    @size = kwargs[:size] || :md
    @btn_text = kwargs[:btn_text]
    @btn_path = kwargs[:btn_path]
    @btn_class = kwargs[:btn_class]
    super
  end

  private

  attr_reader :objet, :header_badges, :start_badges, :tags, :commune, :recensement, :main_photo_origin, :size,
              :btn_text, :btn_class, :btn_path

  delegate :nom, :edifice_nom_formatted, :palissy_photos_presenters, to: :objet

  def path
    @path ||= objet_path(@objet)
  end

  def truncated_nom
    truncate(nom, length: 45)
  end

  def main_photo
    @main_photo ||= {
      memoire: main_photo_palissy,
      recensement: main_photo_recensement,
      recensement_or_memoire: main_photo_recensement || main_photo_palissy
    }[main_photo_origin]
  end

  def link_html_attributes
    { class: "fr-card__link", title: nom.length > 45 ? nom : nil }.compact
      .deep_merge_html_attributes(@link_html_attributes_custom)
      .deep_tidy_html_attributes
  end

  def main_photo_palissy = palissy_photos_presenters&.first

  def main_photo_recensement
    return unless (photo = recensement&.photos&.first)&.variable?

    PhotoPresenter.new \
      url: photo.variant(:medium),
      description: "Objet #{nom} lors du recensement"
  end
end
