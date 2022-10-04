class AddPalissyPhotosToObjets < ActiveRecord::Migration[7.0]
  def change
    add_column :objets, :palissy_photos, :json, array: true, default: []
  end
end
