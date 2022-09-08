class AddEmailNameToCampaignEmails < ActiveRecord::Migration[7.0]
  def change
    add_column :campaign_emails, :email_name, :string
  end
end
