# frozen_string_literal: true

class AddRememberCreatedAtAndLastSignInAtToRecenseurs < ActiveRecord::Migration[7.1]
  def change
    change_table :recenseurs do |t|
      t.datetime :remember_created_at
      t.datetime :last_sign_in_at
    end
  end
end
