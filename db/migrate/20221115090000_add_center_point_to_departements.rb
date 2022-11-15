require "csv"

class AddCenterPointToDepartements < ActiveRecord::Migration[7.0]
  def up
    add_column :departements, :bounding_box_sw, :st_point, geographic: true
    add_column :departements, :bounding_box_ne, :st_point, geographic: true
    factory = RGeo::Geographic.simple_mercator_factory
    CSV.read(Rails.root.join("db/migrate/departements-bounds.csv"), headers: :first_row, col_sep: ',').each do |row|
      puts "settings bounds for #{row}..."
      Departement.find(row["code"]).update_columns(
        bounding_box_ne: factory.point(row["E"], row["N"]),
        bounding_box_sw: factory.point(row["W"], row["S"]),
      )
    end
  end

  def down
    remove_column :departements, :bounding_box_ne
    remove_column :departements, :bounding_box_sw
  end
end
