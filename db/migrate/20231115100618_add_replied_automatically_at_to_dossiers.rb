class AddRepliedAutomaticallyAtToDossiers < ActiveRecord::Migration[7.0]
  def change
    add_column :dossiers, :replied_automatically_at, :datetime
  end
end
