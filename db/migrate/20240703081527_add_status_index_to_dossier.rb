class AddStatusIndexToDossier < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :dossiers, :status, using: :hash, algorithm: :concurrently
  end
end
