class AddEdificeIdsToRecenseurAccess < ActiveRecord::Migration[7.2]
  def change
    change_table :recenseur_accesses do |t|
      t.integer :edifice_ids, array: true, default: [], null: false
      t.boolean :all_edifices, default: true, null: false
    end
  end
end
