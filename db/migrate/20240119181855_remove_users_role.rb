class RemoveUsersRole < ActiveRecord::Migration[7.1]
  def up
    remove_column :users, :role, :string
  end

  def down
    add_column :users, :role, :string
    User.update_all(role: "mairie")
  end
end
