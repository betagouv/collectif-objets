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

ActiveRecord::Schema.define(version: 2022_02_02_153039) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "objets", force: :cascade do |t|
    t.string "ref_pop"
    t.string "ref_memoire"
    t.string "nom"
    t.string "categorie"
    t.string "commune"
    t.string "commune_code_insee"
    t.string "departement"
    t.string "crafted_at"
    t.datetime "last_recolement_at", precision: 6
    t.string "nom_dossier"
    t.string "edifice_nom"
    t.string "emplacement"
    t.string "recolement_status"
    t.string "image_urls", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["commune"], name: "index_objets_on_commune"
    t.index ["commune_code_insee"], name: "index_objets_on_commune_code_insee"
    t.index ["departement"], name: "index_objets_on_departement"
    t.index ["ref_pop"], name: "objets_unique_ref_pop", unique: true
  end

end
