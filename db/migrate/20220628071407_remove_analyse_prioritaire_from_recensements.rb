class RemoveAnalysePrioritaireFromRecensements < ActiveRecord::Migration[7.0]
  def change
    remove_column :recensements, :analyse_prioritaire, :boolean
  end
end
