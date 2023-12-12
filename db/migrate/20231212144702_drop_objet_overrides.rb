class DropObjetOverrides < ActiveRecord::Migration[7.1]
  def up
    objets = Objet.where("palissy_photos::text LIKE '%override%'")
    # je n’arrive pas à écrire la requête SQL correcte sur le json array alors je caste en texte
    puts "Found #{objets.count} objets with palissy_photos override"
    objets.update_all(palissy_photos: [])
    raise if Objet.where("palissy_photos::text LIKE '%override%'").count.positive?
    puts "Removed these photos!"
    drop_table :objet_overrides
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
