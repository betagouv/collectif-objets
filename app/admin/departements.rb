# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Departement do
  menu label: "🧩 Départements", priority: 2
  decorate_with DepartementDecorator
  actions :all, except: %i[destroy new create edit update]

  filter :code

  index do
    id_column
    column :name
    column :communes_count
    column :objets_count
    actions
  end

  show do
    div class: "show-container" do
      div do
        attributes_table title: "🧩 Département ##{departement}" do
          row :name
          row :communes_count
          row :objets_count
        end

        panel "👷‍♀️ Conservateurs" do
          table_for departement.conservateurs.map(&:decorate) do
            column(:id) { link_to _1.id, admin_conservateur_path(_1) }
            column :first_name
            column :last_name
            column :departements
            column :phone_number
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
