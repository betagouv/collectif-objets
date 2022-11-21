class FixRecensementsConfirmationPasDePhotos < ActiveRecord::Migration[7.0]
  def up
    puts "will fix #{buggy_recensements.count} recensements that have confirmation_pas_de_photos but an attached photo"
    buggy_recensements.update_all(confirmation_pas_de_photos: false)
    puts "there are now #{buggy_recensements.count} buggy recensements"
  end

  def down
  end

  private

  def buggy_recensements
    Recensement
      .where(confirmation_pas_de_photos: true)
      .joins(:photos_attachments)
  end
end
