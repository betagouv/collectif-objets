class AddPalissyDproAndProtToObjets < ActiveRecord::Migration[7.0]
  def change
    add_column :objets, :palissy_PROT, :string
    add_column :objets, :palissy_DPRO, :string
  end
end
