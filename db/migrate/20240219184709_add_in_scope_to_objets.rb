class AddInScopeToObjets < ActiveRecord::Migration[7.1]
  def change
    add_column :objets, :in_scope, :boolean, default: true, null: false
    add_column :objets, :in_scope_errors, :json, array: true, null: true
    # add_index :objets, :in_scope
    # add_index :objets, [:in_scope, :lieu_actuel_code_insee]
  end
end
