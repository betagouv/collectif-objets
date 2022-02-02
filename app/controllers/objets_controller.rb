class ObjetsController < ApplicationController
  def index
    @objets = Objet
      .where.not(nom: nil)
      .where.not(commune: nil)
      .where("cardinality(image_urls) >= 1")
      .first(20)
  end
end
