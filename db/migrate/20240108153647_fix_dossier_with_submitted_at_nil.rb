class FixDossierWithSubmittedAtNil < ActiveRecord::Migration[7.1]
  def up
    Commune.joins(:dossier).where(status: :completed).where(dossier: { submitted_at: nil }) do |commune|
      commune.dossier.update(submitted_at: commune.completed_at)
    end
  end
end
