class AddIndexOnObjetsLieuActuelDepartementCode < ActiveRecord::Migration[7.1]
  def change
    add_index :objets, :lieu_actuel_departement_code
  end
end
