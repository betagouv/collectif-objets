class AddConcordataireToDepartements < ActiveRecord::Migration[7.0]
  def up
    add_column :departements, :concordataire, :boolean
    Departement.find("68").update!(concordataire: true)
    Departement.find("67").update!(concordataire: true)
  end

  def down
    remove_column :departements, :concordataire
  end
end
