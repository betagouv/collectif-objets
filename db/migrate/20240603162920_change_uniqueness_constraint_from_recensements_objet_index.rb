class ChangeUniquenessConstraintFromRecensementsObjetIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :recensements, :objet_id, unique: true
    add_index :recensements, [:objet_id, :dossier_id], unique: true
  end
end
