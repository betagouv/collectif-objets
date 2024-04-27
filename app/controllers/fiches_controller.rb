# frozen_string_literal: true

class FichesController < ApplicationController
  helper_method :titre_objets_concernes

  def index
    @fiches = Fiche.all
  end

  def show
    @fiche = Fiche.find(params[:id])
    @objets = objets
  end

  private

  def objets
    return nil unless current_user&.commune&.dossier&.accepted?

    current_user.commune.objets
      .joins(:recensements).includes(:recensements)
      .where("'#{@fiche.id}' = ANY(recensements.analyse_fiches)")
  end

  def titre_objets_concernes
    if @objets.present? && @objets.count > 1
      "Objets concernés par cette fiche"
    else
      "Objet concerné par cette fiche"
    end
  end
end
