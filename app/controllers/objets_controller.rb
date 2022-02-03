class ObjetsController < ApplicationController
  def index
    @filters = {
      commune: params[:commune_code_insee].present? ? Commune.find_by_code_insee(params[:commune_code_insee]) : nil
    }.compact
    @pagy, @objets = pagy(
      Objet
        .where.not(nom: nil)
        .where.not(commune: nil)
        .where(@filters[:commune] ? { commune_code_insee: @filters[:commune].code_insee } : nil)
        .where(@filters.any? ? nil : "cardinality(image_urls) >= 1")
    )
  end

  def show
    @objet = Objet.find(params[:id])
  end
end
