class FixDossierWithSubmittedAtNil < ActiveRecord::Migration[7.1]
  def up
    Commune.joins(:dossier).where(status: :completed).where(dossier: { submitted_at: nil }).find_each do |commune|
      commune.dossier.update!(submitted_at: commune.completed_at)
      puts "Mise à jour du dossier de la commune #{commune.nom} - code insee #{commune.code_insee} - id #{commune.id} avec un submitted_at à #{commune.dossier.submitted_at}"
    end
  end
end
