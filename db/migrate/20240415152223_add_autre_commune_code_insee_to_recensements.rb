class AddAutreCommuneCodeInseeToRecensements < ActiveRecord::Migration[7.1]
  def change
    add_column :recensements, :autre_commune_code_insee, :string
  end
end
