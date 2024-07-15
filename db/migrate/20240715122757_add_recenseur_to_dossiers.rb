class AddRecenseurToDossiers < ActiveRecord::Migration[7.1]
  def change
    add_column :dossiers, :recenseur, :text
  end
end
