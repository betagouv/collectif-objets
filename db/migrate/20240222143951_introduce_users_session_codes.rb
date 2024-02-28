class IntroduceUsersSessionCodes < ActiveRecord::Migration[7.1]
  def change
    # remove unused users devise columns
    remove_column :users, :encrypted_password, :string
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :string

    # remove deprecated users devise columns
    rename_column :users, :magic_token, :magic_token_deprecated
    remove_column :users, :login_token, :string
    remove_column :users, :login_token_valid_until, :datetime

    create_table :session_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :code
      t.datetime :used_at
      t.timestamps
      t.index [:user_id, :created_at]
    end

    # add unsubscribe_token to campaign_recipients
    add_column :campaign_recipients, :unsubscribe_token, :string
    add_index :campaign_recipients, :unsubscribe_token, unique: true
    reversible do |dir|
      dir.up do
        CampaignRecipient
          .joins(:campaign)
          .where.not(campaign: {status: "finished"})
          .find_each do |recipient|
          recipient.set_unsubscribe_token
          recipient.save!
        end
      end
    end

  end
end
