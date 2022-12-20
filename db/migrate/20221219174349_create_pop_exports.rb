class CreatePopExports < ActiveRecord::Migration[7.0]
  def change
    create_table :pop_exports do |t|
      t.string :base, null: false
      t.string :departement_code, null: false

      t.timestamps
    end

    add_column :recensements, :pop_export_memoire_id, :bigint
    add_column :recensements, :pop_export_palissy_id, :bigint
  end
end
