class RejectedDossiersBecomeConstruction < ActiveRecord::Migration[7.0]
  def up
    display_counts_around do
      dossiers = Dossier.where(status: "rejected").joins(:conservateur)
      dossiers.find_each do |dossier|
        Message.create!(
          commune_id: dossier.commune_id,
          author: dossier.conservateur,
          origin: "rejection",
          text: dossier.notes_conservateur
        )
      end
      dossiers.update_all(status: "submitted", notes_conservateur: nil)
    end
  end

  def down
    display_counts_around do
      Dossier.where(status: "submitted").where.not(rejected_at: nil).find_each do |dossier|
        message = dossier.commune.messages.where(origin: "rejection").first
        next if message.nil?
        dossier.update_columns(status: "rejected", notes_conservateur: message.text)
      end
      Message.where(origin: "rejection").destroy_all
    end
  end

  private

  def display_counts
    Dossier.pluck(:status).tally.sort.each { puts "dossiers #{_1} : #{_2}" }
    puts "messages count : #{Message.count}"
  end

  def display_counts_around
    puts "before migration: "
    display_counts
    puts "migrating..."
    yield
    puts "after migration: "
    display_counts
  end
end
