class AddConfirmationSurPlaceAndSkipPhotosToRecensement < ActiveRecord::Migration[7.0]
  def up
    add_column :recensements, :confirmation_sur_place, :boolean
    add_column :recensements, :confirmation_pas_de_photos, :boolean
    Recensement.update_all(confirmation_sur_place: true)
    Recensement.where.missing(:photos_attachments).update_all(confirmation_pas_de_photos: true)
  end

  def down
    remove_column :recensements, :confirmation_sur_place
    remove_column :recensements, :confirmation_pas_de_photos
  end
end
