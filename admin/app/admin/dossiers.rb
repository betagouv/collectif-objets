ActiveAdmin.register Dossier do
  menu label: "📂 Dossiers", priority: 4

  actions :all, except: [:destroy, :new, :create]
  # permit_params :status, :completed_at

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

  # show do
  #   div class: "show-container" do
  #     div do
  #       attributes_table title: "📍 Dossier ##{Dossier.id}" do
  #         row :id
  #       end
  #     end
  #   end
  # end

  # form do |f|
  #   f.semantic_errors # shows errors on :base
  #   f.inputs do
  #     f.input :nom, input_html: { disabled: true }
  #   end
  #   f.actions         # adds the 'Submit' and 'Cancel' buttons
  # end
end
