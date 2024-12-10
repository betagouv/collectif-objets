class AddRecordTypeToSessionCodes < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :session_codes, :users
    remove_index :session_codes, :user_id
    remove_index :session_codes, [:user_id, :created_at]

    rename_column :session_codes, :user_id, :record_id
    add_column :session_codes, :record_type, :string

    up_only do
      SessionCode.update_all(record_type: :User)
      change_column_null :session_codes, :record_type, false
    end

    add_index :session_codes, [:record_id, :record_type]
  end
end
