# frozen_string_literal: true

# rails runner scripts/update_departements_coordinates.rb

require "csv"

factory = RGeo::Geographic.simple_mercator_factory

CSV.read(Rails.root.join("db/migrate/departements-bounds.csv"), headers: :first_row, col_sep: ",").each do |row|
  departement = Departement.find(row["code"])
  if departement.bounding_box_ne.present? && departement.bounding_box_sw.present?
    puts "bounds already set for #{row}"
  else
    puts "setting new bounds for #{row}"
    departement.update_columns(
      bounding_box_ne: factory.point(row["E"], row["N"]),
      bounding_box_sw: factory.point(row["W"], row["S"])
    )
  end
end
