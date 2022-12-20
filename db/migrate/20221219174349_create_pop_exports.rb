class CreatePopExports < ActiveRecord::Migration[7.0]
  def change
    create_table :pop_exports do |t|
      t.string :base, null: false
      t.string :departement_code, null: false

      t.timestamps
    end

    create_join_table :pop_exports, :recensements, table_name: :pop_export_recensements
  end
end
