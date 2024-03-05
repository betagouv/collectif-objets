class AddUserCommuneIdForeignKey < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :users, :communes, column: :commune_id
  end
end
