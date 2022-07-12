# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
ActiveAdmin.register User do
  menu label: "👤 Utilisateurs", priority: 2
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
  filter :commune_departement, as: :check_boxes, collection: -> { Co::Departements.admin_select_options }

  show do
    div class: "show-container" do
      div do
        attributes_table title: "👤 Utilisateur ##{user.id}" do
          row :id
          row :email
          row :role
          row :magic_token
          row :login_token
          row :encrypted_password
          row :role
          row :nom
          row :job_title
          row :email_personal
          row :phone_number
        end

        panel "📍 Commune ##{user.commune.id}" do
          attributes_table_for user.commune.decorate do
            row(:id) { link_to _1.id, admin_commune_path(_1) }
            row :nom
            row :departement
            row :code_insee
            row :status
            row :recensements_summary
            row :enrolled_at
            row :notes_from_enrollment
            row :completed_at
            row :notes_from_completion
          end
        end
      end
      div do
        active_admin_comments
      end
    end
  end

  member_action :rotate_magic_token, method: :put do
    resource.update!(magic_token: SecureRandom.hex(10))
    redirect_to resource_path, notice: "Lien magique mis à jour !"
  end

  action_item :view, only: :show do
    link_to(
      "Rafraîchir le lien magique",
      rotate_magic_token_admin_user_path(user),
      method: "PUT",
      data: {
        confirm: (
          if user.magic_token.present?
            "⚠️ Attention ! un lien magique existe déjà pour cet utilisateur. " \
              "S'il a déjà été partagé avec l'utilisateur, l'ancien ne fonctionnera plus une fois" \
              " que vous l'aurez rafraîchi. êtes-vous sûr.e ?"
          end
        )
      }
    )
  end
end
# rubocop:enable Metrics/BlockLength
