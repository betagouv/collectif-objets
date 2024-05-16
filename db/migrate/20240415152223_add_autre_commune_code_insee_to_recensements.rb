class AddAutreCommuneCodeInseeToRecensements < ActiveRecord::Migration[7.1]
  def up
    add_column :recensements, :autre_commune_code_insee, :string
  end

  def down
    remove_column :recensements, :autre_commune_code_insee, :string

    Recensement.where(localisation: "deplacement_autre_commune").update_all(localisation: "autre_edifice")
    Recensement.where(localisation: "deplacement_temporaire").update_all(localisation: "absent")
  end
end
