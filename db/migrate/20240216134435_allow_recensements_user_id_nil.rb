class AllowRecensementsUserIdNil < ActiveRecord::Migration[7.1]
  def change
    change_column_null :recensements, :user_id, true
  end
end
