class RenameCampaignsRappelToRelance < ActiveRecord::Migration[7.0]
  def change
    rename_column :campaigns, :date_rappel1, :date_relance1
    rename_column :campaigns, :date_rappel2, :date_relance2
    rename_column :campaigns, :date_rappel3, :date_relance3
  end
end
