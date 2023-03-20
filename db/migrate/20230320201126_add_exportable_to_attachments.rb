class AddExportableToAttachments < ActiveRecord::Migration[7.0]
  def change
    add_column :active_storage_attachments, :exportable, :boolean, default: true
  end
end
