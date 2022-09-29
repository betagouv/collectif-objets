class RemoveCampaignRecipientsWithoutUser < ActiveRecord::Migration[7.0]
  def up
    recipients = CampaignRecipient.where_assoc_not_exists([:commune, :users])
    puts "destroying #{recipients.count} campaign recipients without a user..."
    recipients.each { _1.destroy! }
    puts "done!"
  end
end
