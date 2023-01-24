class RemoveFormulaireUpdatedAtFromCommunes < ActiveRecord::Migration[7.0]
  def change
    remove_column :communes, :formulaire_updated_at
  end
end
