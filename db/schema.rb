# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_11_29_152439) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "campaign_emails", force: :cascade do |t|
    t.bigint "campaign_recipient_id"
    t.string "step"
    t.string "sib_message_id"
    t.boolean "sent"
    t.boolean "delivered"
    t.boolean "opened"
    t.boolean "clicked"
    t.string "error"
    t.string "error_reason"
    t.string "subject"
    t.json "headers"
    t.json "sib_events"
    t.datetime "last_sib_synchronization_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email_name"
    t.index ["campaign_recipient_id"], name: "index_campaign_emails_on_campaign_recipient_id"
  end

  create_table "campaign_recipients", force: :cascade do |t|
    t.bigint "campaign_id"
    t.bigint "commune_id"
    t.string "current_step"
    t.boolean "opt_out", default: false
    t.string "opt_out_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "commune_id"], name: "index_campaign_recipients_on_campaign_id_and_commune_id", unique: true
    t.index ["campaign_id"], name: "index_campaign_recipients_on_campaign_id"
    t.index ["commune_id"], name: "index_campaign_recipients_on_commune_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "status", default: "draft", null: false
    t.string "departement_code", null: false
    t.date "date_lancement"
    t.date "date_relance1"
    t.date "date_relance2"
    t.date "date_relance3"
    t.date "date_fin"
    t.string "sender_name"
    t.string "signature"
    t.string "nom_drac"
    t.boolean "imported", default: false
    t.json "stats"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["departement_code"], name: "index_campaigns_on_departement_code"
  end

  create_table "communes", force: :cascade do |t|
    t.string "nom"
    t.string "code_insee"
    t.string "departement_code"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "inactive", null: false
    t.datetime "completed_at"
    t.integer "recensement_ratio"
    t.bigint "dossier_id"
    t.datetime "started_at"
    t.datetime "formulaire_updated_at"
    t.float "latitude"
    t.float "longitude"
    t.index ["code_insee"], name: "communess_unique_code_insee", unique: true
    t.index ["departement_code"], name: "index_communes_on_departement_code"
    t.index ["dossier_id"], name: "index_communes_on_dossier_id"
  end

  create_table "conservateur_roles", force: :cascade do |t|
    t.bigint "conservateur_id"
    t.string "departement_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conservateur_id"], name: "index_conservateur_roles_on_conservateur_id"
    t.index ["departement_code"], name: "index_conservateur_roles_on_departement_code"
  end

  create_table "conservateurs", force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.datetime "last_sign_in_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.index ["email"], name: "index_conservateurs_on_email", unique: true
  end

  create_table "departements", primary_key: "code", id: :string, force: :cascade do |t|
    t.string "nom", null: false
    t.string "service_public_prefix"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dans_nom"
    t.boolean "concordataire"
    t.geography "bounding_box_sw", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.geography "bounding_box_ne", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
  end

  create_table "dossiers", force: :cascade do |t|
    t.bigint "commune_id", null: false
    t.string "status", default: "construction", null: false
    t.datetime "submitted_at"
    t.datetime "rejected_at"
    t.datetime "accepted_at"
    t.string "notes_commune"
    t.string "notes_conservateur"
    t.bigint "conservateur_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commune_id"], name: "dossiers_unique_commune_id", unique: true
    t.index ["conservateur_id"], name: "index_dossiers_on_conservateur_id"
  end

  create_table "objet_overrides", primary_key: "palissy_REF", id: :string, force: :cascade do |t|
    t.string "plan_objet_id"
    t.string "image_urls", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source", null: false
  end

  create_table "objets", force: :cascade do |t|
    t.string "palissy_REF"
    t.string "memoire_REF"
    t.string "palissy_DENO"
    t.string "palissy_CATE"
    t.string "palissy_COM"
    t.string "palissy_INSEE"
    t.string "palissy_DPT"
    t.string "palissy_SCLE"
    t.string "palissy_DENQ"
    t.string "palissy_DOSS"
    t.string "palissy_EDIF"
    t.string "palissy_EMPL"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "palissy_TICO"
    t.json "palissy_photos", default: [], array: true
    t.string "palissy_REFA"
    t.index ["palissy_COM"], name: "index_objets_on_palissy_COM"
    t.index ["palissy_DPT"], name: "index_objets_on_palissy_DPT"
    t.index ["palissy_INSEE"], name: "index_objets_on_palissy_INSEE"
    t.index ["palissy_REF"], name: "objets_unique_ref_pop", unique: true
  end

  create_table "recensements", force: :cascade do |t|
    t.bigint "objet_id", null: false
    t.string "localisation"
    t.boolean "recensable"
    t.string "edifice_nom"
    t.string "etat_sanitaire"
    t.string "etat_sanitaire_edifice"
    t.string "securisation"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "analyse_etat_sanitaire"
    t.string "analyse_etat_sanitaire_edifice"
    t.string "analyse_securisation"
    t.string "analyse_actions", default: [], array: true
    t.string "analyse_fiches", default: [], array: true
    t.text "analyse_notes"
    t.datetime "analysed_at"
    t.bigint "conservateur_id"
    t.bigint "dossier_id", null: false
    t.boolean "confirmation_sur_place"
    t.boolean "confirmation_pas_de_photos"
    t.index ["conservateur_id"], name: "index_recensements_on_conservateur_id"
    t.index ["dossier_id"], name: "index_recensements_on_dossier_id"
    t.index ["objet_id"], name: "index_recensements_on_objet_id", unique: true
    t.index ["user_id"], name: "index_recensements_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "last_sign_in_at"
    t.string "login_token"
    t.datetime "login_token_valid_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "commune_id"
    t.string "magic_token"
    t.string "role", null: false
    t.string "nom"
    t.string "job_title"
    t.string "email_personal"
    t.string "phone_number"
    t.index ["commune_id"], name: "index_users_on_commune_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["magic_token"], name: "index_users_on_magic_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "dossiers", "communes"
  add_foreign_key "recensements", "objets"
  add_foreign_key "recensements", "users"
end
