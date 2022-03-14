# frozen_string_literal: true

class CreateObjets < ActiveRecord::Migration[7.0]
  def change
    create_table :objets do |t|
      t.string :ref_pop, index: { unique: true, name: "objets_unique_ref_pop"}
      t.string :ref_memoire
      t.string :nom
      t.string :categorie
      t.string :commune, index: true
      t.string :commune_code_insee, index: true
      t.string :departement, index: true
      t.string :crafted_at
      t.datetime :last_recolement_at
      t.string :nom_dossier
      t.string :edifice_nom
      t.string :emplacement
      t.string :recolement_status
      t.string :image_urls, array: true, default: []

      t.timestamps
    end
  end
end
