class CreateTableObjetsOverrides < ActiveRecord::Migration[7.0]
  def change
    create_table(:objet_overrides, id: false) do |t|
      t.string :palissy_REF, primary_key: true
      t.string :plan_objet_id
      t.string :image_urls, array: true

      t.timestamps
    end
  end
end
