ActiveAdmin.register Objet do
  decorate_with ObjetDecorator

  actions :all, except: [:destroy, :new, :create, :edit, :update]

  index do
    id_column
    column :ref_pop
    column :nom
    column :nom_courant
    column :commune
    column :edifice_nom
    column :emplacement
    column :image_urls
    column :categorie
    column :crafted_at
    column :created_at
    actions
  end

  filter :commune_departement, :as => :check_boxes, collection: Commune.select(:departement).distinct.pluck(:departement).compact.sort
  filter :commune
  filter :ref_pop_equals
  filter :nom
  filter :nom_courant
  filter :categorie
  filter :edifice_nom
  filter :emplacement

  show do
    div class: "show-container" do
      div do
        attributes_table do
          row :ref_pop
          row :ref_memoire
          row :nom
          row :nom_courant
          row :commune
          row :edifice_nom
          row :emplacement
          row :image_urls
          row :categorie
          row :crafted_at
          row :image_urls
          row :nom_dossier
          row :created_at
        end

        panel "Recensements" do
          table_for objet.recensements.map(&:decorate) do
            column(:id) { link_to _1.id, admin_recensement_path(_1) }
            column :created_at
            column :localisation
            column :edifice_nom
            column :recensable
            column :etat_sanitaire_edifice
            column :etat_sanitaire
            column :securisation
            column :notes_truncated
            column :first_photo_img
          end
        end
      end
      div do
        active_admin_comments
      end
    end
  end
end
