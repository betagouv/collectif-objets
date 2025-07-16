class AddStateToBordereauRecensements < ActiveRecord::Migration[7.2]
  def change
    add_column :bordereau_recensements, :etat_sanitaire, :string
  end
end
