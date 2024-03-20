class AddAutreEdificeIdToRecensement < ActiveRecord::Migration[7.1]
  def change
    add_reference :recensements, :edifice, foreign_key: true
  end
end
