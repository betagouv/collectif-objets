class AddArchivedAtToDossiers < ActiveRecord::Migration[7.1]
  def change
    add_column :dossiers, :archived_at, :datetime
  end
end
