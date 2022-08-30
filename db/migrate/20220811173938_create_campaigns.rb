class CreateCampaigns < ActiveRecord::Migration[7.0]
  def up
    create_table :campaigns do |t|
      t.string :status, null: false, default: "draft"
      t.string :departement_code, null: false, index: true
      t.date :date_lancement
      t.date :date_rappel1
      t.date :date_rappel2
      t.date :date_rappel3
      t.date :date_fin

      t.string :sender_name
      t.string :signature
      t.string :nom_drac

      t.boolean :imported, default: false
      t.json :stats

      t.timestamps
    end

    create_table :campaign_recipients do |t|
      t.references :campaign
      t.references :commune
      t.string :current_step
      t.boolean :opt_out, default: false
      t.string :opt_out_reason

      t.timestamps
      t.index [:campaign_id, :commune_id], unique: true
    end

    create_table :campaign_emails do |t|
      t.references :campaign_recipient
      t.string :step
      t.string :sib_message_id
      t.boolean :sent
      t.boolean :delivered
      t.boolean :opened
      t.boolean :clicked
      t.string :error
      t.string :error_reason
      t.string :subject
      t.string :raw_html
      t.json :headers
      t.json :sib_events
      t.datetime :last_sib_synchronization_at
      t.timestamps
    end

    add_column :departements, :dans_nom, :string
    rename_column :departements, :name, :nom
    CSV.read(Rails.root.join("db/migrate/noms_departements.csv"), headers: :first_row, col_sep: ',').each do |row|
      Departement.find(row["code"]).update_columns(nom: row["nom"], dans_nom: row["dans_nom"])
    end
  end

  def down
    rename_column :departements, :nom, :name
    remove_column :departements, :dans_nom, :string
    drop_table :campaigns
    drop_table :campaign_emails
    drop_table :campaign_recipients
  end
end
