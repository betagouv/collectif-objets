class AddRecensementRatioToCommunes < ActiveRecord::Migration[7.0]
  def up
    add_column :communes, :recensement_ratio, :integer
    RefreshCommuneRecensementRatioJob.perform_now("all")
  end

  def down
    remove_column :communes, :recensement_ratio
  end
end
