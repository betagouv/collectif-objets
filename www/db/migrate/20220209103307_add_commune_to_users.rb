class AddCommuneToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :commune, index: true
  end
end
