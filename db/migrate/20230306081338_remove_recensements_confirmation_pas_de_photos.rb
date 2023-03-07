class RemoveRecensementsConfirmationPasDePhotos < ActiveRecord::Migration[7.0]
  def up
    remove_column :recensements, :confirmation_pas_de_photos
    add_column :recensements, :photos_count, :integer, default: 0
    Recensement.reset_column_information
    RefreshRecensementPhotosCountJob.perform_inline
  end

  def down
    remove_column :recensements, :photos_count
    add_column :recensements, :confirmation_pas_de_photos, :boolean
    Recensement.update_all(confirmation_pas_de_photos: false)
    Recensement.where.missing(:photos_attachments).update_all(confirmation_pas_de_photos: true)
  end
end
