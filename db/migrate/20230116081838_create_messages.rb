class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :inbound_emails, id: false do |t|
      t.string :id, unique: true, primary_key: true
      t.string :body_html
      t.string :body_text
      t.string :body_md
      t.string :signature_md
      t.string :from_email
      t.string :to_email
      t.string :sent_at
      t.json :raw
    end

    create_table :messages do |t|
      t.string :origin
      t.references :commune, null: false, foreign_key: true
      t.string :inbound_email_id, null: true, foreign_key: true
      t.bigint :author_id
      t.string :author_type
      t.string :text
      t.string :automated_mail_name

      t.timestamps
    end
  end
end
