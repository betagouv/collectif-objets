class AddCommunesCountToDepartements < ActiveRecord::Migration[7.1]
  def change
    add_column :departements, :communes_count, :integer, null: false, default: 0

    unless reverting?
      # Set counter for all objects in one query, without instanciating all models
      execute <<-SQL.squish
        UPDATE departements SET communes_count = (SELECT count(1) FROM communes WHERE communes.departement_code = departements.code)
      SQL
    end
  end
end
