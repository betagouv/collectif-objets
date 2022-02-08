class AddNomCourantToObjets < ActiveRecord::Migration[7.0]
  def change
    add_column :objets, :nom_courant, :string
  end
end
