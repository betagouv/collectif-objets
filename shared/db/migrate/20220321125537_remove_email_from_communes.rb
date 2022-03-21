class RemoveEmailFromCommunes < ActiveRecord::Migration[7.0]
  def up
    remove_column :communes, :email
    remove_column :communes, :population
  end
end
