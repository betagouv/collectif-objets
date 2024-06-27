class RemoveUniquenessConstraintFromDossiersCommuneIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :dossiers, :commune_id, unique: true
    add_index :dossiers, :commune_id
  end
end
