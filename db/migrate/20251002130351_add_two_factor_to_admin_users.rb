class AddTwoFactorToAdminUsers < ActiveRecord::Migration[7.2]
  def change
    change_table :admin_users do |t|
      t.string  :otp_secret
      t.integer :consumed_timestep
      t.boolean :otp_required_for_login, null: false, default: false
    end
  end
end
