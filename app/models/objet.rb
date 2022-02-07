class Objet < ApplicationRecord
  scope :with_images, -> { where("cardinality(image_urls) >= 1") }
  belongs_to :commune, foreign_key: :commune_code_insee, primary_key: :code_insee
end
