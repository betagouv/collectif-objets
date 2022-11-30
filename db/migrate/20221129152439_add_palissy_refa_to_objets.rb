class AddPalissyRefaToObjets < ActiveRecord::Migration[7.0]
  def change
    add_column :objets, :palissy_REFA, :string
  end
end
