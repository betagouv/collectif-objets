class FixNonRecensableRecensements < ActiveRecord::Migration[7.0]
  TRUNCATE_COLS = %w[edifice_nom etat_sanitaire etat_sanitaire_edifice securisation]

  def up
    absent_but_recensable = Recensement.where(
      localisation: Recensement::LOCALISATION_ABSENT,
      recensable: true
    )
    puts "will set recensable false on #{absent_but_recensable.count} recensements absents but recensable ..."
    absent_but_recensable.update_all(recensable: false)
    puts "there are now #{absent_but_recensable.count} recensements absents but recensable"

    puts "---"

    not_recensable_but_infos_filled = Recensement.where(recensable: false).where(
      TRUNCATE_COLS.map { "#{_1} IS NOT NULL" }.join(" OR ")
    )
    puts "will truncate infos filled on #{not_recensable_but_infos_filled.count} recensements not recensable but with infos ..."
    not_recensable_but_infos_filled.update_all(TRUNCATE_COLS.map { [_1, nil] }.to_h)
    puts "there are now #{not_recensable_but_infos_filled.count} recensements not recensable but with infos"

    puts "---"

    not_recensable_but_photos_attached = Recensement.where(recensable: false).where_assoc_exists(:photos_attachments)
    puts "will truncate photos filled on #{not_recensable_but_photos_attached.count} recensements not recensable but with photos ..."
    not_recensable_but_photos_attached.to_a.each do |recensement|
      recensement.photos.purge
    end
    puts "there are now #{not_recensable_but_photos_attached.count} recensements not recensable but with photos"
  end
end
