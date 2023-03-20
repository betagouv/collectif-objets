# frozen_string_literal: true

class ObjetCardComponent < ViewComponent::Base
  using HTMLAttributesUtils

  with_collection_parameter :objet

  def initialize(objet = nil, **kwargs)
    @objet = objet || kwargs[:objet]
    @badges = kwargs[:badges]
    @path = kwargs[:path]
    @main_photo = kwargs[:main_photo]
    @tags = kwargs[:tags]
    @commune = kwargs[:commune] || @objet.commune # pass to avoid n+1 queries
    @link_html_attributes_custom = kwargs[:link_html_attributes] || {}
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

  def main_photo
    @main_photo || palissy_photos&.first
  end

  def link_html_attributes
    { class: "fr-card__link" }
      .deep_merge_html_attributes(@link_html_attributes_custom)
      .deep_tidy_html_attributes
  end
end
