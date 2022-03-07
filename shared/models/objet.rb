# frozen_string_literal: true

class Objet < ApplicationRecord
  scope :with_images, -> { where("cardinality(image_urls) >= 1") }
  belongs_to :commune, foreign_key: :commune_code_insee, primary_key: :code_insee, optional: true, inverse_of: :objets
  has_many :recensements

  scope :with_photos_first, -> { order("cardinality(image_urls) DESC, LOWER(nom) ASC") }
  scope :without_recensement, -> { includes(:recensements).where(recensements: { objet_id: nil }) }

  def self.displayable
    in_str = Commune::DISPLAYABLE_DEPARTEMENTS.map { "'#{_1}'" }.join(", ")
    where.not(nom: nil)
      .where.not(commune: nil)
      .where("SUBSTR(commune_code_insee, 0, 3) IN (#{in_str})")
  end

  def nom_formatted
    (nom_courant || nom).capitalize
  end

  def edifice_nom_formatted
    if edifice_nom == "église" && commune.present?
      "Une église de #{commune.nom}"
    else
      edifice_nom&.capitalize
    end
  end

  def first_image_url
    image_urls&.first
  end

  def nom_with_ref_pop
    "#{ref_pop} #{nom}"
  end

  def current_recensement
    recensements.first
  end

  def recensement?
    current_recensement.present?
  end

  def recensable?
    current_recensement.nil? && commune.objets_recensable?
  end
end
