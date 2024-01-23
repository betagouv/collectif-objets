# frozen_string_literal: true

class FichesController < ApplicationController
  helper_method :titre_objets_concernes

  def index
    @fiches = Fiche.load_all
  end

  def show
    raise ActiveRecord::RecordNotFound if Fiche.all_ids.exclude? params[:id]

    @fiche = Fiche.load_from_id(params[:id])
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
