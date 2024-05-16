class RemoveConfirmationSurPlaceFromRecensements < ActiveRecord::Migration[7.1]
  def up
    remove_column :recensements, :confirmation_sur_place, :boolean
  end

  def down
    add_column :recensements, :confirmation_sur_place, :boolean

    execute <<-SQL.squish
      UPDATE recensements SET confirmation_sur_place = true
    SQL
  end
end
