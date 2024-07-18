class RemoveExtraneousTextFromRecensementsNotes < ActiveRecord::Migration[7.1]
  def up
    say_with_time "Supprime le texte 'loca' en fin de notes dans les recensements" do
      Recensement.where("notes like '%\nloca'").find_each do |recensement|
        recensement.update(notes: recensement.notes.gsub(/\nloca\Z/, ""))
      end
    end
  end
end
