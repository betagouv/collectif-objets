class AddSupportEmailTokenToCommunes < ActiveRecord::Migration[7.0]
  def up
    add_column :communes, :inbound_email_token, :string
    Commune.find_each { _1.update_columns(inbound_email_token: SecureRandom.hex(10)) }
    change_column :communes, :inbound_email_token, :string, null: false
  end

  def down
    remove_column :communes, :inbound_email_token
  end
end
