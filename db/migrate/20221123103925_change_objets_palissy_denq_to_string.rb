class ChangeObjetsPalissyDenqToString < ActiveRecord::Migration[7.0]
  def change
    change_column(:objets, :palissy_DENQ, :string)
  end
end
