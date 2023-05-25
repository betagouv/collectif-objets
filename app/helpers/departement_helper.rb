# frozen_string_literal: true

module DepartementHelper
  def departements_options
    Departement.order(:code).map { [_1, _1.code] }
  end
end
