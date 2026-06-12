class AddDeviseTwoFactorBackupableToAdminUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :admin_users, :otp_backup_codes, :string, array: true
  end
end
