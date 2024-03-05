class RemoveUserIdFromRecensements < ActiveRecord::Migration[7.1]
  def change
    remove_column :recensements, :user_id, :integer
  end
end
