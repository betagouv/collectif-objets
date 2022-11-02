class PrepareConservateursRecensementsOnEdifices < ActiveRecord::Migration[7.0]
  def change
    change_column_null :recensements, :user_id, true
    reversible { _1.down { Recensement.where(user_id: nil).delete_all } }
    add_reference :dossiers, :edifice
    reversible { _1.down { Dossier.where.not(edifice_id: nil).delete_all } }
    add_column :dossiers, :author_role, :string
    reversible { _1.up { Dossier.update_all(author_role: "user") } }
    change_column_null :dossiers, :author_role, false
    remove_index :dossiers, name: "dossiers_unique_commune_id", column: [:commune_id], unique: true
    add_index :dossiers, :commune_id
  end
end
