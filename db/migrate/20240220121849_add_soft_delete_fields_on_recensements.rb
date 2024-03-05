class AddSoftDeleteFieldsOnRecensements < ActiveRecord::Migration[7.1]
  def change
    add_column :recensements, :deleted_at, :datetime
    add_column :recensements, :deleted_reason, :string
    add_column :recensements, :deleted_message, :string
    add_column :recensements, :deleted_objet_snapshot, :jsonb
    add_index :recensements, :deleted_at

    change_column_null :recensements, :objet_id, true
  end
end
