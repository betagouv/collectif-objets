class AddObjetsCountToCommunes < ActiveRecord::Migration[7.1]
  def change
    add_column :communes, :objets_count, :integer, null: false, default: 0

    unless reverting?
      # Set counter in one query, without instanciating all models
      execute <<-SQL.squish
        UPDATE communes SET objets_count = (SELECT count(1) FROM objets WHERE objets.lieu_actuel_code_insee = communes.code_insee)
      SQL
    end
  end
end
