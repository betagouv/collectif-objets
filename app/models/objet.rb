# frozen_string_literal: true

class Objet < ApplicationRecord
  scope :with_images, -> { where("cardinality(image_urls) >= 1") }
  belongs_to :commune, foreign_key: :commune_code_insee, primary_key: :code_insee, optional: true

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
end
