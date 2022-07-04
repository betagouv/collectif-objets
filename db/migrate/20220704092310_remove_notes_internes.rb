class RemoveNotesInternes < ActiveRecord::Migration[7.0]
  def change
    remove_column :dossiers, :notes_conservateur_private, :string
    remove_column :objets, :notes_conservateur, :string
    remove_column :objets, :notes_conservateur_at, :datetime
    remove_reference :objets, :conservateur
  end
end
