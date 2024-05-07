class CreateEmptyDossierForCommunesWithoutDossier < ActiveRecord::Migration[7.1]
  def up
    Commune.where(dossier_id: nil).find_each do |commune|
      dossier = commune.create_dossier(status: :empty, commune_id: commune.id)
      commune.update(dossier:)
    end
  end

  def down
    dossier_ids = Dossier.empty.ids
    Dossier.empty.delete_all
    Commune.where(dossier_id: dossier_ids).update_all(dossier_id: nil)
  end
end
