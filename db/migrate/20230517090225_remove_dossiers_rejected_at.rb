class RemoveDossiersRejectedAt < ActiveRecord::Migration[7.0]
  def up
    dossiers = Dossier
      .where.not(rejected_at: nil)
      .where(status: :submitted)
      .where.not(notes_conservateur: nil)
      .where.not(commune_id: Message.where(origin: "rejection").pluck(:commune_id))

    puts "créé #{dossiers.count} messages de rejection manquants"
    dossiers.find_each do |dossier|
      Message.create! \
        commune_id: dossier.commune_id,
        author: dossier.conservateur,
        origin: "rejection",
        text: dossier.notes_conservateur,
        created_at: dossier.rejected_at
      puts "message créé pour #{dossier.commune}"
    end
    dossiers.update_all(notes_conservateur: nil)

    remove_column :dossiers, :rejected_at, :datetime
  end

  def down
    add_column :dossiers, :rejected_at, :datetime
  end
end
