class UpdateNomsDepartements < ActiveRecord::Migration[7.1]
  def up
    CSV.read(Rails.root.join("db/migrate/noms_departements.csv"), headers: :first_row, col_sep: ',').each do |row|
      Departement.find(row["code"]).update_columns(nom: row["nom"], dans_nom: row["dans_nom"])
    end
  end
end
