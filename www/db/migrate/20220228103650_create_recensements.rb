class CreateRecensements < ActiveRecord::Migration[7.0]
  def change
    create_table :recensements do |t|
      t.references :objet, null: false, foreign_key: true
      t.string :localisation
      t.boolean :recensable
      t.string :edifice_nom
      t.string :etat_sanitaire
      t.string :etat_sanitaire_edifice
      t.string :securisation
      t.string :notes

      t.timestamps
    end
  end
end
