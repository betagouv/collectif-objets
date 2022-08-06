class AddLatitudeLongitudeToCommunes < ActiveRecord::Migration[7.0]
  def change
    add_column :communes, :latitude, :float
    add_column :communes, :longitude, :float
  end
end
