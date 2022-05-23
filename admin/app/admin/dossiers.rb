ActiveAdmin.register Dossier do
  menu label: "📂 Dossiers", priority: 4

  actions :all, except: [:destroy, :new, :create]
  permit_params :status, :notes_commune, :notes_conservateur, :notes_conservateur_private

  index do
    id_column
    column :commune_id
    column :conservateur
    column :status
    column :notes_commune
    column :notes_conservateur
    column :notes_conservateur_private
    column :created_at
    column :updated_at
    column :pending_at
    column :rejected_at
    column :done_at
    actions
  end

  show do
    div class: "show-container" do
      div do
        attributes_table title: "📂 Dossier ##{dossier.id}" do
          row :id
          row :status
          row :submitted_at
          row :rejected_at
          row :accepted_at
          row :pdf_updated_at
          row :notes_commune
          row :notes_conservateur
          row :notes_conservateur_private
          row :created_at
          row :updated_at
        end

        panel "📍 Commune ##{dossier.commune.id}" do
          attributes_table_for dossier.commune do
            row(:id) { link_to _1.id, admin_commune_path(_1) }
            row :nom
            row :departement
            row :code_insee
            row :status
            row :recensements_summary, label: "Recensements"
            row :enrolled_at
            row :notes_from_enrollment
            row :completed_at
          end
        end

        if dossier.conservateur.present?
          panel "👷‍♀️ Conservateur #{dossier.conservateur}" do
            attributes_table_for dossier.conservateur.decorate do
              row(:id) { link_to _1.id, admin_conservateur_path(_1) }
              row :email
              row :first_name
              row :last_name
              row :departements
              row :phone_number
            end
          end
        end

        panel "✍️ Recensements" do
          table_for dossier.recensements.map(&:decorate) do
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
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      f.input :status, as: :select, collection: Dossier.aasm.states_for_select
      f.input :notes_commune
      f.input :notes_conservateur
      f.input :notes_conservateur_private
    end
    f.actions         # adds the 'Submit' and 'Cancel' buttons
  end
end
