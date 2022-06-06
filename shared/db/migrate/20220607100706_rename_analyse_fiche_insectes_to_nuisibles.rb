class RenameAnalyseFicheInsectesToNuisibles < ActiveRecord::Migration[7.0]
  def up
    Recensement.where("analyse_fiches @> '{insectes}'").each do |recensement|
      recensement.update_columns(analyse_fiches: recensement.analyse_fiches - ["insectes"] + ["nuisibles"])
    end
  end

  def down
    Recensement.where("analyse_fiches @> '{nuisibles}'").each do |recensement|
      recensement.update_columns(analyse_fiches: recensement.analyse_fiches - ["nuisibles"] + ["insectes"])
    end
  end
end
