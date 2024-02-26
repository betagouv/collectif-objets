class NullifyUserIdOnDeletedRecensements < ActiveRecord::Migration[7.1]
  def up
    Recensement.only_deleted.update_all(user_id: nil)
  end
  def down; end
end
