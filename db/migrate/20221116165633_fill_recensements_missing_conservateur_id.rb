class FillRecensementsMissingConservateurId < ActiveRecord::Migration[7.0]
  def up
    recensements_with_missing_conservateur
      .joins(dossier: [:commune])
      .where.not({ dossiers: { conservateur_id: nil}})
      .each do |recensement|
        puts "updating recensement #{recensement.id} with conservateur #{recensement.dossier.conservateur}"
        recensement.update!(conservateur: recensement.dossier.conservateur)
      end

    [
      { code_insee: "21040", nom: "Avosnes", conservateur: "adeline-e.riviere" },
      { code_insee: "21100", nom: "Brain", conservateur: "adeline-e.riviere" },
      { code_insee: "21173", nom: "Chorey-les-Beaune", conservateur: "adeline-e.riviere" },
      { code_insee: "21197", nom: "Corpoyer-la-Chapelle", conservateur: "adeline-e.riviere" },
      { code_insee: "21304", nom: "Grancey-le-Château-Neuvelle", conservateur: "chb.hd.b.francois" },
      { code_insee: "21596", nom: "Savouges", conservateur: "adeline-e.riviere" },
      { code_insee: "51141", nom: "La Chaussée-sur-Marne", conservateur: "frederic.murienne" },
      { code_insee: "51204", nom: "Damery", conservateur: "frederic.murienne" },
      { code_insee: "51485", nom: "Saint-Hilaire-au-Temple", conservateur: "frederic.murienne" },
      { code_insee: "51513", nom: "Saint-Rémy-en-Bouzemont-Saint-Genest-et-Isson", conservateur: "frederic.murienne" },
      { code_insee: "59159", nom: "Craywick", conservateur: "marie.boudeele" },
      { code_insee: "59436", nom: "Noordpeene", conservateur: "marie.boudeele" },
      { code_insee: "59436", nom: "Warhem", conservateur: "marie.boudeele" },
    ].each do |row|
      recensements = recensements_with_missing_conservateur
        .joins(dossier: [:commune])
        .where({ dossiers: { conservateur_id: nil}})
        .where(communes: { code_insee: row[:code_insee] })
      conservateur = Conservateur.where(%(email LIKE '#{row[:conservateur]}%')).first!
      puts "setting conservateur = #{conservateur} on #{recensements.count} recensements from #{row[:nom]}..."
      recensements.update_all(conservateur_id: conservateur.id)
      puts "done!"
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
