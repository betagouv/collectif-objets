class RenamePopFields < ActiveRecord::Migration[7.0]
  def change
    rename_column :objets, :ref_pop, :palissy_REF
    rename_column :objets, :ref_memoire, :memoire_REF
    rename_column :objets, :nom, :palissy_DENO
    rename_column :objets, :categorie, :palissy_CATE
    rename_column :objets, :commune_nom, :palissy_COM
    rename_column :objets, :commune_code_insee, :palissy_INSEE
    rename_column :objets, :departement, :palissy_DPT
    rename_column :objets, :crafted_at, :palissy_SCLE
    rename_column :objets, :last_recolement_at, :palissy_DENQ
    rename_column :objets, :nom_dossier, :palissy_DOSS
    rename_column :objets, :edifice_nom, :palissy_EDIF
    rename_column :objets, :emplacement, :palissy_EMPL
    rename_column :objets, :nom_courant, :palissy_TICO
  end
end
