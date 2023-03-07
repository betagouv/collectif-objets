class AddRecensementsStatus < ActiveRecord::Migration[7.0]
  def up
    add_column :recensements, :status, :string, default: "draft", null: false
    Recensement.update_all(status: "completed")
    change_column_null :recensements, :dossier_id, true
  end

  def down
    Recensement.where(status: "draft").delete_all
    Recensement.where(dossier_id: nil).delete_all
    change_column_null :recensements, :dossier_id, false
    remove_column :recensements, :status
  end
end
