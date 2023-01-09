class RemoveAnalyseActionsFromRecensements < ActiveRecord::Migration[7.0]
  def up
    remove_column :recensements, :analyse_actions
  end

  def down
    add_column :recensements, :analyse_actions, :string, array: true, default: []
  end
end
