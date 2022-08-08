# frozen_string_literal: true

class ObjetsController < ApplicationController
  def index
    @filters = {
      commune: params[:commune_code_insee].present? ? Commune.find_by(code_insee: params[:commune_code_insee]) : nil
    }.compact
    @pagy, @objets = pagy(filtered_objets.with_photos_first)
  end

  def show
    @objet = Objet.find(params[:id])
  end

  def show_by_ref_pop
    @objet = Objet.find_by(palissy_REF: params[:palissy_REF])
    render :show
  end

  private

  def filtered_objets
    o = Objet.all
    o = o.where(commune_code_insee: @filters[:commune].code_insee) if @filters[:commune]
    o = o.where_assoc_exists(:commune) if @filters[:commune].blank?
    o
  end
end
