class CreateConservateursTable < ActiveRecord::Migration[7.0]
  def change
    create_table :conservateurs do |t|
      t.string :email, null: false
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :departements, default: [], array: true
      t.datetime :last_sign_in_at
      t.string :login_token
      t.datetime :login_token_valid_until
      t.datetime :remember_created_at

      t.timestamps
    end
    add_index :conservateurs, :email, unique: true
  end
end
