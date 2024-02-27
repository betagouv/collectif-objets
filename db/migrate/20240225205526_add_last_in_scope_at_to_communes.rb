class AddLastInScopeAtToCommunes < ActiveRecord::Migration[7.1]
  def change
    add_column :communes, :last_in_scope_at, :datetime
  end
end
