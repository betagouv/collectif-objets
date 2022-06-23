class AddFormulaireToCommunes < ActiveRecord::Migration[7.0]
  def change
    add_column :communes, :formulaire_updated_at, :datetime
  end
end
