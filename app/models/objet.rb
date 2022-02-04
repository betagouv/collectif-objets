class Objet < ApplicationRecord
  scope :with_images, -> { where("cardinality(image_urls) >= 1") }
end
