class CommuneResource < Avo::BaseResource
  self.title = :nom_with_code_insee
  self.includes = []
  self.search_query = ->(params:) do
    scope.ransack(
      id_eq: params[:q],
      nom_cont: params[:q],
      code_insee_cont: params[:q],
      departement_cont: params[:q],
      m: "or"
    ).result(distinct: true)
  end

  field :id, as: :id, link_to_resource: true
  field :nom, as: :text, sortable: true, link_to_resource: true, readonly: true
  field :code_insee, as: :text, sortable: true, readonly: true
  field :departement, sortable: true, as: :text, readonly: true
  field(
    :status,
    as: :text,
    format_using: ->(status) {
      return "" if status.blank?
      color = status == Commune::STATUS_COMPLETED ? "green-500" : "blue-500"
      label = [
        [Commune::STATUS_ENROLLED, "Inscrite"],
        [Commune::STATUS_STARTED, "Démarré"],
        [Commune::STATUS_COMPLETED, "Terminé"],
      ].to_h[status]
      "<span class=\"whitespace-nowrap rounded-md uppercase px-2 py-1 text-xs font-bold block text-center truncate bg-#{color} text-white\" style=\"max-width: 120px;\">#{label}</span>".html_safe
    },
    sortable: true
  )
  field(
    :status,
    as: :select,
    hide_on: [:show, :index],
    options: {
      "Aucun statut": nil,
      "Commune Inscrite": Commune::STATUS_ENROLLED,
      "Recensement démarré": Commune::STATUS_STARTED,
      "Recensement terminé": Commune::STATUS_COMPLETED,
    },
    placeholder: "Statut"
  )
  # field :email, sortable: true, as: :text
  field :phone_number, sortable: true, as: :text
  field :population, sortable: true, as: :number
  field :notes_from_enrollment, as: :text, hide_on: [:index]
  field :notes_from_completion, as: :text, hide_on: [:index]
  field :enrolled_at, as: :text, sortable: true, format_using: ->(t) { t && I18n.l(t, locale: :fr, format: :short)  }, readonly: true
  field :completed_at, as: :text, sortable: true, format_using: ->(t) { t && I18n.l(t, locale: :fr, format: :short)  }, readonly: true

  field :users, as: :has_many
  field :objets, as: :has_many
  field :recensements, as: :has_many, through: :objets

  filter CommuneStatusFilter
  filter DepartementFilter
end
