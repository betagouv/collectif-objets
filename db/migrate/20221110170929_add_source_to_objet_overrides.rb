class AddSourceToObjetOverrides < ActiveRecord::Migration[7.0]
  def up
    add_column :objet_overrides, :source, :string
    ObjetOverride.update_all(source: "2022_09_ariege")
    change_column_null :objet_overrides, :source, false
  end

  def down
    remove_column :objet_overrides, :source
  end
end
