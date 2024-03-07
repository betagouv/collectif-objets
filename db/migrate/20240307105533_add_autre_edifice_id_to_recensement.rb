class AddAutreEdificeIdToRecensement < ActiveRecord::Migration[7.1]
  def change
    add_column :recensements, :autre_edifice_id, :integer
  end
end
