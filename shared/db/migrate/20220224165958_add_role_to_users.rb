class AddRoleToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :role, :string
    change_column_null :users, :role, false, "mairie"
  end
end
