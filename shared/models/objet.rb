# frozen_string_literal: true

class Objet < ApplicationRecord
  scope :with_images, -> { where("cardinality(image_urls) >= 1") }
  belongs_to :commune, foreign_key: :commune_code_insee, primary_key: :code_insee, optional: true, inverse_of: :objets
  has_many :recensements

  scope :with_photos_first, -> { order("cardinality(image_urls) DESC, LOWER(nom) ASC") }

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

  def airtable_questionnaire_link
    get_params = {
      "prefill_Nom de l'objet": nom_formatted,
      "prefill_Référence Palissy de l'objet": ref_pop,
      "prefill_⛪ Liste propriétaires 2": commune&.nom,
      "prefill_Édifice concerné": edifice_nom_formatted
    }
    "https://airtable.com/shrHSC6DqdqkzBQjF?#{get_params.to_query}"
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
end
