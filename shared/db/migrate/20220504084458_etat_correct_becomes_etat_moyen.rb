class EtatCorrectBecomesEtatMoyen < ActiveRecord::Migration[7.0]
  def up
    change_values(from: "correct", to: "moyen")
  end

  def down
    change_values(from: "moyen", to: "correct")
  end

  protected

  def change_values(from:, to:)
    [:etat_sanitaire, :etat_sanitaire_edifice].each do |attr_name|
      arel = Recensement.where(attr_name => from)
      puts "will update #{arel.count}/#{Recensement.count} recensements' #{attr_name} from #{from} to #{to}..."
      arel.update_all(attr_name => to)
      puts "done"
    end
  end
end
