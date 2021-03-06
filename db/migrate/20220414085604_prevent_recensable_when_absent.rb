class PreventRecensableWhenAbsent < ActiveRecord::Migration[7.0]
  def up
    Recensement.recensable.absent.find_each do |recensement|
      recensement.update_columns(recensable: false)
    end
  end

  def down; end
end
