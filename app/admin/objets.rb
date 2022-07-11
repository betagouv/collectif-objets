# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Objet do
  menu label: "🖼 Objets", priority: 3
  decorate_with ObjetDecorator

  actions :all, except: %i[destroy new create edit update]

  index do
    id_column
    column :palissy_REF
    column :palissy_DENO
    column :palissy_TICO
    column :commune
    column :palissy_EDIF
    column :palissy_EMPL
    column :image_urls
    column :palissy_CATE
    column :palissy_SCLE
    column :created_at
    actions
  end

  filter :commune_departement, as: :check_boxes, collection: Co::Departements.admin_select_options
  filter :commune
  filter :palissy_REF_equals
  filter :palissy_DENO
  filter :palissy_TICO
  filter :palissy_CATE
  filter :palissy_EDIF
  filter :palissy_EMPL

  show do
    div class: "show-container" do
      div do
        attributes_table title: "🖼 Objet ##{objet.id}" do
          row :ref_pop
          row :ref_memoire
          row :palissy_DENO
          row :palissy_TICO
          row :commune
          row :palissy_EDIF
          row :palissy_EMPL
          row :image_urls
          row :palissy_CATE
          row :palissy_SCLE
          row :image_urls
          row :palissy_DOSS
          row :created_at
        end

        panel "✍️ Recensements" do
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
# rubocop:enable Metrics/BlockLength
