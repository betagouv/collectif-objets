class CreateRecenseurs < ActiveRecord::Migration[7.1]
  def change
    create_table :recenseurs do |t|
      t.string :email, null: false
      t.string :status, null: false, default: :pending
      t.string :nom
      t.text :notes

      t.timestamps

      t.index :email, unique: true
    end
  end
end
