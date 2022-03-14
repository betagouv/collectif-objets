ActiveAdmin.register Recensement do
  actions :all, except: [:destroy, :new, :create, :edit, :update]
  decorate_with RecensementDecorator

  index do
    id_column
    column :objet
    column :commune
    column :created_at
    column :localisation
    column :edifice_nom
    column :recensable
    column :etat_sanitaire_edifice
    column :etat_sanitaire
    column :securisation
    column :notes_truncated
    column :first_photo_img
    actions
  end

  filter :objet_commune_departement, :as => :check_boxes, collection: Commune.select(:departement).distinct.pluck(:departement).compact.sort
  filter :localisation, as: :check_boxes, collection: Recensement::LOCALISATIONS
  filter :edifice_nom
  filter :recensable
  filter :etat_sanitaire_edifice, as: :check_boxes, collection: Recensement::ETATS
  filter :etat_sanitaire, as: :check_boxes, collection: Recensement::ETATS
  filter :securisation, as: :check_boxes, collection: Recensement::SECURISATIONS
  filter :notes

  show do
    div class: "show-container" do
      div do
        attributes_table do
          row :id
          row :objet
          row :commune
          row :localisation
          row :edifice_nom
          row :recensable
          row :etat_sanitaire_edifice
          row :etat_sanitaire
          row :securisation
          row :notes
          row :photos_imgs
          row :created_at
          row :updated_at
        end
      end
      div do
        active_admin_comments
      end
    end
  end
end
