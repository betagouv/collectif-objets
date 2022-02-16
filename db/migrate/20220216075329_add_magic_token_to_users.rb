class AddMagicTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :magic_token, :string, unique: true
  end
end
