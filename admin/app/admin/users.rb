ActiveAdmin.register User do
  decorate_with UserDecorator

  actions :all, except: [:destroy]
  permit_params :magic_token, :role, :nom, :job_title, :email_personal, :phone_number

  index do
    id_column
    column :email
    column :role
    column :commune
    column :magic_token
    actions
  end

  filter :email
  filter :role, as: :check_boxes, collection: ["mairie"]
  filter :commune_departement, :as => :check_boxes, collection: Commune.select(:departement).distinct.pluck(:departement).compact.sort

  show do
    div class: "show-container" do
      div do
        attributes_table do
          row :id
          row :email
          row :role
          row :magic_token
          row :login_token
          row :commune
          row :encrypted_password
        end
      end
      div do
        active_admin_comments
      end
    end
  end

end
