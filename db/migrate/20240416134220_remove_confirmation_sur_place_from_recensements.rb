class RemoveConfirmationSurPlaceFromRecensements < ActiveRecord::Migration[7.1]
  def change
    remove_column :recensements, :confirmation_sur_place, :boolean
  end
end
