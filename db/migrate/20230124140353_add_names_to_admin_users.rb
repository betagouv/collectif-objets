class AddNamesToAdminUsers < ActiveRecord::Migration[7.0]
  NAMES = {
    "romuald.goudeseune@culture.gouv.fr" => { first_name: "Romuald", last_name: "Goudeseune"},
    "adrien.di_pasquale@beta.gouv.fr" => { first_name: "Adrien", last_name: "Di Pasquale"},
    "sybille.de-la-raudiere@beta.gouv.fr" => { first_name: "Sybille", last_name: "de La Raudière"},
    "raphaelle.neyton@beta.gouv.fr" => { first_name: "Raphaëlle", last_name: "Neyton"},
    "enora.bulting@beta.gouv.fr" => { first_name: "Enora", last_name: "Bulting"},
    "stephane.maniaci@beta.gouv.fr" => { first_name: "Stéphane", last_name: "Maniaci"},
    "fantine.monot@beta.gouv.fr" => { first_name: "Fantine", last_name: "Monot"},
  }.freeze

  def up
    add_column :admin_users, :first_name, :string
    add_column :admin_users, :last_name, :string
    AdminUser.all.each do |admin_user|
      admin_user.update!(**NAMES.fetch(admin_user.email))
    end
    change_column :admin_users, :first_name, :string, null: false
    change_column :admin_users, :last_name, :string, null: false
  end

  def down
    remove_column :admin_users, :first_name
    remove_column :admin_users, :last_name
  end
end
