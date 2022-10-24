class RemoveRawHtmlFromCampaignEmails < ActiveRecord::Migration[7.0]
  def change
    remove_column :campaign_emails, :raw_html, :string
  end
end
