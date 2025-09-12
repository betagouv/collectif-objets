class CreateRecenseurAccesses < ActiveRecord::Migration[7.1]
  def change
    create_table :recenseur_accesses do |t|
      t.belongs_to :recenseur, null: false, foreign_key: true
      t.belongs_to :commune, null: false, foreign_key: true
      t.boolean :granted

      t.timestamps

      t.index [:recenseur_id, :commune_id], unique: true
    end
  end
end
