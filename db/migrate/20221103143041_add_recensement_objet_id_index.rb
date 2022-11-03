class AddRecensementObjetIdIndex < ActiveRecord::Migration[7.0]
  def up
    remove_index :recensements, :objet_id
    add_index :recensements, :objet_id, unique: true
  end

  def down
    remove_index :recensements, :objet_id
    add_index :recensements, :objet_id
  end
end
