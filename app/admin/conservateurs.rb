# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Conservateur do
  menu label: "👷‍♀️ Conservateurs", priority: 7
  decorate_with ConservateurDecorator

  actions :all, except: [:destroy]

  index do
    id_column
    column :email
    column :first_name
    column :last_name
    column :departements
    column :phone_number
    actions
  end

  filter :email
  filter :departements, as: :check_boxes, collection: -> { Departement.order(:code).all }

  show do
    div class: "show-container" do
      div do
        attributes_table title: "👷‍♀️ Conservateur ##{conservateur.id}" do
          row :id
          row :email
          row :first_name
          row :last_name
          row :departements
          row :phone_number
          row :last_sign_in_at
        end
      end
      div do
        active_admin_comments
      end
    end
  end

  permit_params :email, :first_name, :last_name, :phone_number, :password, :password_confirmation, departement_ids: []

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :phone_number
      f.input :departements, label: "Départements (choix multiples avec shift ou alt !)", as: :check_boxes
    end
    f.actions # adds the 'Submit' and 'Cancel' buttons
  end

  controller do
    def sanitize_params
      params[:conservateur][:departements] = params[:conservateur][:departements]&.map(&:presence)&.compact
    end

    def update
      sanitize_params
      super
    end

    def create
      sanitize_params
      password = SecureRandom.hex(25)
      params[:conservateur][:password] = password
      params[:conservateur][:password_confirmation] = password
      super
    end
  end

  member_action :reset_password, method: :post do
    next if resource.last_sign_in_at?

    resource.send_reset_password_instructions
    redirect_to resource_path(resource), notice: "Mail d'invitation envoyé"
  end

  action_item :reset_password_action, only: :show do
    next if resource.last_sign_in_at?

    link_to(
      "📤 Envoyer mail d'invitation",
      reset_password_admin_old_conservateur_path(resource),
      method: "POST",
      data: {
        confirm:
          "Êtes-vous sûr·e de vouloir envoyer le mail d'invitation pour définir le mot de passe ?" \
          "Les liens envoyés dans d'éventuels mails précédents seront invalidés."
      }
    )
  end
end
# rubocop:enable Metrics/BlockLength
