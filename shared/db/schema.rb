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

ActiveRecord::Schema[7.0].define(version: 2022_03_03_143829) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "communes", force: :cascade do |t|
    t.string "nom"
    t.string "code_insee"
    t.string "departement"
    t.string "email"
    t.string "phone_number"
    t.integer "population"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "recolement_status"
    t.string "image_urls", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nom_courant"
    t.index ["commune_code_insee"], name: "index_objets_on_commune_code_insee"
    t.index ["commune_nom"], name: "index_objets_on_commune_nom"
    t.index ["departement"], name: "index_objets_on_departement"
    t.index ["ref_pop"], name: "objets_unique_ref_pop", unique: true
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
    t.index ["commune_id"], name: "index_users_on_commune_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["magic_token"], name: "index_users_on_magic_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
