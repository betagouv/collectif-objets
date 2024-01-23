class CreateDepartementsBoundingBoxCoordinates < ActiveRecord::Migration[7.1]
  def up
    add_column :departements, :bounding_box, :string, array: true, default: [], null: false
    departements = Departement.all.to_a
    departements.each do |departement|
      departement.update!(
        bounding_box: [
          departement.bounding_box_ne.coordinates,
          departement.bounding_box_sw.coordinates
        ]
      )
    end
    remove_column :departements, :bounding_box_sw
    remove_column :departements, :bounding_box_ne
  end

  def down
    factory = RGeo::Geographic.simple_mercator_factory
    add_column :departements, :bounding_box_sw, :point, geographic: true
    add_column :departements, :bounding_box_ne, :point, geographic: true
    departements = Departement.all.to_a
    departements.each do |departement|
      departement.update!(
        bounding_box_ne: factory.point(departement.bounding_box[0][0], departement.bounding_box[0][1]),
        bounding_box_sw: factory.point(departement.bounding_box[1][0], departement.bounding_box[1][1])
      )
    end
    remove_column :departements, :bounding_box
  end
end
