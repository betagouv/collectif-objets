# frozen_string_literal: true

class CreateCommunes < ActiveRecord::Migration[7.0]
  def change
    create_table :communes do |t|
      t.string :nom
      t.string :code_insee, index: { unique: true, name: "communess_unique_code_insee"}
      t.string :departement, index: true
      t.string :email
      t.string :phone_number
      t.integer :population

      t.timestamps
    end
  end
end
