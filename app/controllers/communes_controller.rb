class CommunesController < ApplicationController
  def index
    @communes_by_dpt = Commune.
      where.not(nom: nil).
      where.not(departement: nil).
      include_objets_count.
      order(:departement, :nom).
      all.to_a.group_by(&:departement)
  end
end
