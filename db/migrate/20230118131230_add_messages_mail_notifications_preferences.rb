class AddMessagesMailNotificationsPreferences < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :messages_mail_notifications, :boolean, default: true
    add_column :conservateurs, :messages_mail_notifications, :boolean, default: true
  end
end
