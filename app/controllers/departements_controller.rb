# frozen_string_literal: true

class DepartementsController < ApplicationController
  def index
    @departements = Departement.all.include_objets_count.include_communes_count
    @map_departements_json = @departements.map { serialize_departement(_1) }.to_json
    set_departements_map_bins
  end

  def show
    @departement = Departement.find(params[:id])
    @communes = @departement.communes.include_objets_count.order(:nom)
    @title = "Liste des communes #{@departement.dans_nom} (#{@departement.code})"
  end

  def set_departements_map_bins
    @map_bins = [
      { threshold: 2000, legend: "moins de 2000 objets protégés" },
      { threshold: 3000, legend: "de 2000 à 3000 objets protégés" },
      { threshold: 4000, legend: "de 3000 à 4000 objets protégés" },
      { threshold: 5000, legend: "de 4000 à 5000 objets protégés" },
      { threshold: 10_000, legend: "plus de 5000 objets protégés" }
    ]
  end

  def serialize_departement(departement)
    {
      code: departement.code,
      nom: departement.nom,
      communesCount: departement.communes_count,
      objetsCount: departement.objets_count
    }
  end
end
