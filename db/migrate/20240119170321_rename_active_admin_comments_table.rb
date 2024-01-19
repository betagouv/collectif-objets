class RenameActiveAdminCommentsTable < ActiveRecord::Migration[7.1]
  def change
    rename_table :active_admin_comments, :admin_comments
    remove_column :admin_comments, :namespace, :string
  end
end
