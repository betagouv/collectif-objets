# frozen_string_literal: true

module DepartementHelper
  def nom_departement(departement_number, with_number: true)
    nom = Co::Departements::NAMES[departement_number]
    with_number ? "#{nom} (#{departement_number})" : nom
  end
end
