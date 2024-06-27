class RemoveRecensementRatioFromCommunes < ActiveRecord::Migration[7.1]
  def change
    remove_column :communes, :recensement_ratio
  end
end
