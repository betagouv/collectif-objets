# frozen_string_literal: true

class ObjetsController < ApplicationController
  def index
    @filters = {
      commune: params[:commune_code_insee].present? ? Commune.find_by(code_insee: params[:commune_code_insee]) : nil
    }.compact
    if @filters[:commune]
      @objets_list = Co::Communes::ObjetsList.new(@filters[:commune])
      @pagy, @objets = pagy(@objets_list.objets)
    else
      @pagy, @objets = pagy(Objet.where_assoc_exists(:commune).with_photos_first)
    end
  end

  def show
    @objet = Objet.find(params[:id])
  end

  def show_by_ref_pop
    @objet = Objet.find_by(palissy_REF: params[:palissy_REF])
    render :show
  end
end
