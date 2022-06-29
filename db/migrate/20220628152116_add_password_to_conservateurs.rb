class AddPasswordToConservateurs < ActiveRecord::Migration[7.0]
  def change
    add_column :conservateurs, :encrypted_password, :string, default: "", null: false
    add_column :conservateurs, :reset_password_token, :string
    add_column :conservateurs, :reset_password_sent_at, :datetime
    remove_column :conservateurs, :login_token, :string
    remove_column :conservateurs, :login_token_valid_until, :datetime

    up_only do
      Conservateur.all.to_a.each do |conservateur|
        puts "setting new random password for #{conservateur}"
        conservateur.update!(password: SecureRandom.hex(10))
      end
    end
  end
end
