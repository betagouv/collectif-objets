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

ActiveRecord::Schema[7.0].define(version: 2022_03_24_090317) do
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
    t.string "notes_from_completion"
    t.datetime "enrolled_at"
    t.datetime "completed_at"
    t.integer "recensement_ratio"
    t.index ["code_insee"], name: "communess_unique_code_insee", unique: true
    t.index ["departement"], name: "index_communes_on_departement"
  end

  create_table "objets", force: :cascade do |t|
    t.string "ref_pop"
    t.string "ref_memoire"
    t.string "nom"
    t.string "categorie"
    t.string "commune_nom"
    t.string "commune_code_insee"
    t.string "departement"
    t.string "crafted_at"
    t.datetime "last_recolement_at"
    t.string "nom_dossier"
    t.string "edifice_nom"
    t.string "emplacement"
    t.string "image_urls", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nom_courant"
    t.index ["commune_code_insee"], name: "index_objets_on_commune_code_insee"
    t.index ["commune_nom"], name: "index_objets_on_commune_nom"
    t.index ["departement"], name: "index_objets_on_departement"
    t.index ["ref_pop"], name: "objets_unique_ref_pop", unique: true
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
  add_foreign_key "recensements", "objets"
  add_foreign_key "recensements", "users"
end
