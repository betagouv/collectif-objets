# frozen_string_literal: true

class CommunesController < ApplicationController
  def index
    @communes_by_dpt = Commune
      .where.not(nom: nil)
      .where(departement: Commune::DISPLAYABLE_DEPARTEMENTS)
      .include_objets_count
      .order(:departement, :nom)
      .all.to_a.group_by(&:departement)
  end
end
