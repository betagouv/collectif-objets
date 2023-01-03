class AddRecipientsCountToCampaigns < ActiveRecord::Migration[7.0]
  def up
    add_column :campaigns, :recipients_count, :integer, default: 0
    Campaign.find_each { Campaign.reset_counters(_1.id, :recipients) }
  end

  def down
    remove_column :campaigns, :recipients_count
  end
end
