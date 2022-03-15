ActiveAdmin.register Commune do
  menu label: "📍 Communes", priority: 1
  decorate_with CommuneDecorator

  actions :all, except: [:destroy, :new, :create]
  permit_params :status, :notes_from_enrollment, :notes_from_completion

  index do
    id_column
    column :nom
    column :departement
    column :code_insee
    column :status
    column :enrolled_at
    column :completed_at
    actions
  end

  filter :departement, :as => :check_boxes, collection: Commune.select(:departement).distinct.pluck(:departement).compact.sort
  filter :nom
  filter :code_insee_equals
  filter(
    :status,
    as: :check_boxes,
    collection: [
      ["Commune Inscrite", Commune::STATUS_ENROLLED],
      ["Recensement démarré", Commune::STATUS_STARTED],
      ["Recensement terminé", Commune::STATUS_COMPLETED],
    ]
  )

  show do
    div class: "show-container" do
      div do
        attributes_table title: "📍 Commune ##{commune.id}" do
          row :id
          row :nom
          row :departement
          row :code_insee
          row :status
          row :enrolled_at
          row :notes_from_enrollment
          row :completed_at
          row :notes_from_completion
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
            column :ref_pop
            column :nom_courant
            column :edifice_nom
            column :emplacement
            column :image_urls
            column :categorie
            column :crafted_at
            column :created_at
          end
        end

        panel "✍️ Recensements" do
          table_for commune.recensements.map(&:decorate) do
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

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      f.input :nom, input_html: { disabled: true }
      f.input :code_insee, input_html: { disabled: true }
      f.input :departement, input_html: { disabled: true }
      f.input :status, as: :select, collection: Commune::STATUSES
    end
    f.actions         # adds the 'Submit' and 'Cancel' buttons
  end
end
