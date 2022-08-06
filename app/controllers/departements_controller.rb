# frozen_string_literal: true

class DepartementsController < ApplicationController
  def index
    @departements = Co::Departements.models(include_communes_count: true)
  end

  def show
    raise unless Co::Departements.numbers.include?(params[:id])

    @departement = Co::Departement.from_number(params[:id])

    @communes = Commune
      .where(departement: params[:id])
      .include_objets_count
      .order(:nom)
  end
end
