class AddIndexObjetsLieuActuelCodeInsee < ActiveRecord::Migration[7.1]
  def change
    add_index :objets, :lieu_actuel_code_insee
  end
end
