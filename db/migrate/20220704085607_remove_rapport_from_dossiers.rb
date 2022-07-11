class RemoveRapportFromDossiers < ActiveRecord::Migration[7.0]
  def change
    remove_column :dossiers, :pdf_updated_at, :datetime
  end
end
