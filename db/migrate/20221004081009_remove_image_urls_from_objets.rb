class RemoveImageUrlsFromObjets < ActiveRecord::Migration[7.0]
  def change
    remove_column :objets, :image_urls
  end
end
