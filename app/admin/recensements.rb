# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Recensement do
  menu label: "✍️ Recensements", priority: 6
  actions :all, except: %i[destroy new create edit update]
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

  filter :objet_commune_departement_code, as: :select, collection: -> { Departement.all }
  filter :localisation, as: :check_boxes, collection: Recensement::LOCALISATIONS
  filter :edifice_nom
  filter :recensable
  filter :etat_sanitaire_edifice, as: :check_boxes, collection: Recensement::ETATS
  filter :etat_sanitaire, as: :check_boxes, collection: Recensement::ETATS
  filter :securisation, as: :check_boxes, collection: Recensement::SECURISATIONS
  filter :notes
  filter :photos_presence, as: :check_boxes, collection: [["Manquantes", false]]

  show do
    div class: "show-container" do
      div do
        attributes_table title: "✍️ Recensement ##{recensement.id}" do
          row :id
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

        panel "🖼 Objet ##{recensement.objet.id}" do
          attributes_table_for recensement.objet.decorate do
            row(:id) { link_to _1.id, admin_objet_path(_1) }
            row :palissy_REF
            row :palissy_TICO
            row :palissy_EDIF
            row :palissy_EMPL
            row :image_urls
            row :palissy_CATE
            row :palissy_SCLE
            row :created_at
          end
        end

        panel "📍 Commune ##{recensement.commune.id}" do
          attributes_table_for recensement.commune do
            row(:id) { link_to _1.id, admin_commune_path(_1) }
            row :nom
            row :departement
            row :code_insee
            row :phone_number
            row :status
            row :recensements_summary, label: "Recensements"
            row :enrolled_at
            row :notes_from_enrollment
            row :completed_at
          end
        end

        panel "📂 Dossier ##{recensement.dossier.id}" do
          attributes_table_for recensement.dossier do
            row(:id) { link_to _1.id, admin_dossier_path(_1) }
            row :status
            row :submitted_at
            row :rejected_at
            row :accepted_at
            row :pdf_updated_at
            row :notes_commune
            row :notes_conservateur
            row :created_at
            row :updated_at
          end
        end
      end
      div do
        active_admin_comments
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
