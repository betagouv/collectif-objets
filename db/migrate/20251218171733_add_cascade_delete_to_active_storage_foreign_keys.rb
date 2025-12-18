# frozen_string_literal: true

class AddCascadeDeleteToActiveStorageForeignKeys < ActiveRecord::Migration[7.2]
  def up
    # Remove existing foreign keys
    remove_foreign_key :active_storage_attachments, :active_storage_blobs
    remove_foreign_key :active_storage_variant_records, :active_storage_blobs

    # Re-add them with cascade delete
    add_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id, on_delete: :cascade
    add_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id, on_delete: :cascade
  end

  def down
    # Remove cascade foreign keys
    remove_foreign_key :active_storage_attachments, :active_storage_blobs
    remove_foreign_key :active_storage_variant_records, :active_storage_blobs

    # Re-add them without cascade (original Rails default)
    add_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id
    add_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id
  end
end
