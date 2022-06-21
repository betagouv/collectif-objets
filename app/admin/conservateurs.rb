# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Conservateur do
  menu label: "👷‍♀️ Conservateurs", priority: 6
  # decorate_with UserDecorator

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
    collection: -> { Conservateur.select(:departements).pluck(:departements).flatten.uniq.compact.sort }
  )

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
          row :login_token
        end
      end
      div do
        active_admin_comments
      end
    end
  end

  permit_params :email, :first_name, :last_name, :phone_number, departements: []

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
        collection: (Range.new(1, 99).map(&:to_s).map{ _1.rjust(2, "0") } + %w[2A 2B 971 972 973]).sort
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
      super
    end
  end
end
# rubocop:enable Metrics/BlockLength
