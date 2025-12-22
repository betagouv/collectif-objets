# frozen_string_literal: true

class AddDeviseLockableToAdminUsers < ActiveRecord::Migration[7.2]
  def change
    change_table :admin_users do |t|
      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at
      t.index    :unlock_token, unique: true
    end
  end
end
