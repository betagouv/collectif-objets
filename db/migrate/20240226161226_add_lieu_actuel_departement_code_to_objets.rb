class AddLieuActuelDepartementCodeToObjets < ActiveRecord::Migration[7.1]
  def up
    add_column :objets, :lieu_actuel_departement_code, :string

    # this could be done with a simple update! by objet but it’s a bit too slow
    Objet.order(:lieu_actuel_code_insee).find_in_batches(batch_size: 1000) do |batch|
      batch
        .group_by { Departement.parse_from_code_insee(_1.lieu_actuel_code_insee) }
        .each do |departement_code, objets|
          Objet
            .where(id: objets.pluck(:id))
            .update_all(lieu_actuel_departement_code: departement_code)
        end
    end
  end

  def down
    remove_column :objets, :lieu_actuel_departement_code
  end
end
