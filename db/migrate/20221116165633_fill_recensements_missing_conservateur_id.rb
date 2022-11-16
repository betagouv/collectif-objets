class FillRecensementsMissingConservateurId < ActiveRecord::Migration[7.0]
  def up
    recensements_with_missing_conservateur
      .joins(:dossier)
      .where.not({ dossiers: { conservateur_id: nil}})
      .each do |recensement|
        puts "updating recensement #{recensement.id} with conservateur #{recensement.dossier.conservateur}"
        recensement.update!(conservateur: recensement.dossier.conservateur)
      end

      puts "there are #{recensements_with_missing_conservateur.count} recensements with a missing conservateur left"
  end

  def down
  end

  private

  def recensements_with_missing_conservateur
    Recensement
      .where.not(analysed_at: nil)
      .where(conservateur_id: nil)
  end
end
