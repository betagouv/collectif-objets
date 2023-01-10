# frozen_string_literal: true

class FichesController < ApplicationController
  def index
    @fiches = Fiche.load_all
  end

  def show
    raise ArgumentError if Fiche.all_ids.exclude? params[:id]

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
end
