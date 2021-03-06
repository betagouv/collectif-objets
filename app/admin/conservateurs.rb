# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Conservateur do
  menu label: "👷‍♀️ Conservateurs", priority: 6
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
  filter(
    :with_departement,
    as: :select,
    collection: -> { Co::Departements.admin_select_options(restrict_communes: false) }
  )

  show do
    div class: "show-container" do
      div do
        attributes_table title: "👷‍♀️ Conservateur ##{conservateur.id}" do
          row :id
          row :email
          row :first_name
          row :last_name
          row :departements_with_names
          row :phone_number
        end
      end
      div do
        active_admin_comments
      end
    end
  end

  permit_params :email, :first_name, :last_name, :phone_number, :password, :password_confirmation, departements: []

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      f.input(:email, (f.object.new_record? ? {} : { input_html: { disabled: true } }))
      f.input :first_name
      f.input :last_name
      f.input :phone_number
      f.input(
        :departements,
        as: :check_boxes,
        collection: Co::Departements.admin_select_options(restrict_communes: false)
      )
    end
    f.actions         # adds the 'Submit' and 'Cancel' buttons
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
end
# rubocop:enable Metrics/BlockLength
