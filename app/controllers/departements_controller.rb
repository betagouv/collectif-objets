# frozen_string_literal: true

class DepartementsController < ApplicationController
  def index
    @departements = Departement.all.include_objets_count.include_communes_count
  end

  def show
    @departement = Departement.find(params[:id])
    @communes = @departement.communes.include_objets_count.order(:nom)
  end
end
