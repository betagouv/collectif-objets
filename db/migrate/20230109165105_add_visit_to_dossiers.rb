class AddVisitToDossiers < ActiveRecord::Migration[7.0]
  def change
    add_column :dossiers, :visit, :string
  end
end
