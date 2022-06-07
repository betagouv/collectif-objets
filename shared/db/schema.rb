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

ActiveRecord::Schema[7.0].define(version: 2022_06_07_100706) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "communes", force: :cascade do |t|
    t.string "nom"
    t.string "code_insee"
    t.string "departement"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "inactive", null: false
    t.string "notes_from_enrollment"
    t.datetime "enrolled_at"
    t.datetime "completed_at"
    t.integer "recensement_ratio"
    t.bigint "dossier_id"
    t.datetime "started_at"
    t.index ["code_insee"], name: "communess_unique_code_insee", unique: true
    t.index ["departement"], name: "index_communes_on_departement"
    t.index ["dossier_id"], name: "index_communes_on_dossier_id"
  end

  create_table "conservateurs", force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "departements", default: [], array: true
    t.datetime "last_sign_in_at"
    t.string "login_token"
    t.datetime "login_token_valid_until"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_conservateurs_on_email", unique: true
  end

  create_table "dossiers", force: :cascade do |t|
    t.bigint "commune_id", null: false
    t.string "status", default: "construction", null: false
    t.datetime "submitted_at"
    t.datetime "rejected_at"
    t.datetime "accepted_at"
    t.datetime "pdf_updated_at"
    t.string "notes_commune"
    t.string "notes_conservateur"
    t.string "notes_conservateur_private"
    t.bigint "conservateur_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commune_id"], name: "dossiers_unique_commune_id", unique: true
    t.index ["conservateur_id"], name: "index_dossiers_on_conservateur_id"
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
    t.datetime "palissy_DENQ"
    t.string "palissy_DOSS"
    t.string "palissy_EDIF"
    t.string "palissy_EMPL"
    t.string "image_urls", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "palissy_TICO"
    t.string "notes_conservateur"
    t.datetime "notes_conservateur_at"
    t.bigint "conservateur_id"
    t.index ["conservateur_id"], name: "index_objets_on_conservateur_id"
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
    t.boolean "analyse_prioritaire"
    t.datetime "analysed_at"
    t.bigint "conservateur_id"
    t.bigint "dossier_id", null: false
    t.index ["conservateur_id"], name: "index_recensements_on_conservateur_id"
    t.index ["dossier_id"], name: "index_recensements_on_dossier_id"
    t.index ["objet_id"], name: "index_recensements_on_objet_id"
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
