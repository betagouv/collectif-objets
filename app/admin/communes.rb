# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Commune do
  menu label: "📍 Communes", priority: 1
  decorate_with CommuneDecorator

  actions :all, except: %i[destroy new create]
  permit_params :notes_from_enrollment

  collection_action :export_sib, method: :get do
    send_data(
      SibExportCommunesCsv.new(params[:departement]).perform,
      filename: "export.csv",
      type: "text/csv",
      disposition: "attachment; filename=export.csv"
    )
  end

  index do
    # selectable_column
    id_column
    column :nom
    column :departement
    column :code_insee
    column :status
    column :first_user_email
    column :objets_count
    column :recensements_summary, label: "Recensements"
    column :enrolled_at
    column :completed_at
    actions
  end

  csv do
    column :id
    column :nom
    column :departement
    column :code_insee
    column :status
    column :first_user_email
    column :recensement_ratio
    column :recensements_photos_present
    column :enrolled_at
    column :completed_at
  end

  filter :departement, as: :check_boxes, collection: -> { Co::Departements.admin_select_options }
  filter :nom
  filter :code_insee_equals
  filter(
    :status,
    as: :check_boxes,
    collection: [
      ["Commune inactive", Commune::STATE_INACTIVE],
      ["Commune Inscrite", Commune::STATE_ENROLLED],
      ["Recensement démarré", Commune::STATE_STARTED],
      ["Recensement terminé", Commune::STATE_COMPLETED]
    ]
  )
  filter(
    :recensements_photos_presence,
    as: :check_boxes,
    collection: [
      ["Manquantes", false]
    ]
  )
  filter :recensement_ratio

  show do
    div class: "show-container" do
      div do
        attributes_table title: "📍 Commune ##{commune.id}" do
          row :id
          row :nom
          row :departement_with_name
          row :code_insee
          row :status
          row :recensements_summary, label: "Recensements"
          row :notes_from_enrollment
          row :started_at
          row :enrolled_at
          row :completed_at
        end

        commune.users.map(&:decorate).each do |user|
          panel "👤 User ##{user.id}" do
            attributes_table_for user do
              row(:id) { link_to _1.id, admin_user_path(_1) }
              row :email
              row :role
              row :magic_token
              row :role
              row :nom
              row :job_title
              row :email_personal
              row :phone_number
            end
          end
        end

        panel "🖼 Objets" do
          table_for commune.objets.map(&:decorate) do
            column(:id) { link_to _1.id, admin_objet_path(_1) }
            column :palissy_REF
            column :palissy_TICO
            column :palissy_EDIF
            column :palissy_EMPL
            column :image_urls
            column :palissy_CATE
            column :palissy_SCLE
            column :created_at
          end
        end

        panel "📂 Dossiers" do
          table_for commune.past_dossiers do
            column(:id) { link_to _1.id, admin_dossier_path(_1) }
            column :status
            column :created_at
          end
        end

        panel "✍️ Recensements" do
          table_for commune.recensements.map(&:decorate) do
            column(:id) { link_to _1.id, admin_recensement_path(_1) }
            column :dossier_id
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

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      f.input :nom, input_html: { disabled: true }
      f.input :code_insee, input_html: { disabled: true }
      f.input :departement, input_html: { disabled: true }
      f.input :status, as: :select, collection: Commune.aasm.states_for_select, input_html: { disabled: true }
      f.input :notes_from_enrollment, as: :text, input_html: { rows: 2 }
    end
    f.actions         # adds the 'Submit' and 'Cancel' buttons
  end

  member_action :return_dossier_to_construction, method: :post do
    resource.dossier.return_to_construction!
    redirect_to resource_path
  end

  action_item :return_dossier_to_construction_action, only: :show do
    next unless resource.dossier&.can_return_to_construction?

    link_to(
      "Repasser en recensement démarré",
      return_dossier_to_construction_admin_commune_path(resource),
      method: "POST"
    )
  end
end
# rubocop:enable Metrics/BlockLength
