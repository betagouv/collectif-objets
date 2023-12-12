class DropObjetOverrides < ActiveRecord::Migration[7.1]
  def up
    drop_table :objet_overrides
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
