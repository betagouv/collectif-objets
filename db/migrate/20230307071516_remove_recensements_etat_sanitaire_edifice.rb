class RemoveRecensementsEtatSanitaireEdifice < ActiveRecord::Migration[7.0]
  def change
    remove_column :recensements, :etat_sanitaire_edifice
  end
end
