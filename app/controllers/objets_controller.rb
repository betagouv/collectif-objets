class ObjetsController < ApplicationController
  def index
    @pagy, @objets = pagy(
      Objet
        .where.not(nom: nil)
        .where.not(commune: nil)
        .where("cardinality(image_urls) >= 1")
    )

  end

  def show
    @objet = Objet.find(params[:id])
  end
end
