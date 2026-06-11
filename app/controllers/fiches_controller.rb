# frozen_string_literal: true

class FichesController < ApplicationController
  helper_method :titre_objets_concernes

  def index
    @fiches = Fiche.all.sort_by(&:id)
  end

  def show
    @fiche = Fiche.find(params[:id])
    @objets = objets
  end

  private

  # rubocop:disable Style/SafeNavigationChainLength
  def objets
    return nil unless current_user&.commune&.dossier&.accepted?

    current_user.commune.objets
      .joins(:recensements).includes(:recensements)
      .where("'#{@fiche.id}' = ANY(recensements.analyse_fiches)")
  end
  # rubocop:enable Style/SafeNavigationChainLength

  def titre_objets_concernes
    if @objets.present? && @objets.many?
      "Objets concernés par cette fiche"
    else
      "Objet concerné par cette fiche"
    end
  end
end
