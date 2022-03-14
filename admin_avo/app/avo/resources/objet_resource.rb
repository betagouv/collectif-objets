class ObjetResource < Avo::BaseResource
  self.title = :nom_with_ref_pop
  self.includes = []
  self.search_query = ->(params:) do
    scope.ransack(
      id_eq: params[:q],
      ref_pop_eq: params[:q],
      nom_courant_cont: params[:q],
      nom_cont: params[:q],
      m: "or"
    ).result(distinct: false)
  end

  field :id, as: :id
  field :ref_pop, as: :text, sortable: true, link_to_resource: true, readonly: true
  field :nom_courant, as: :text, sortable: true, readonly: true
  field :first_image_url, as: :external_image, readonly: true
  field :nom, as: :text, hide_on: [:index], readonly: true
  field :commune, as: :belongs_to, searchable: true, readonly: true
  field :categorie, as: :text, sortable: true, readonly: true
  field :crafted_at, as: :datetime, sortable: true, readonly: true
  field :departement, as: :text, sortable: true, hide_on: [:index], readonly: true
  field :recolement_status, as: :text, sortable: true
  field :edifice_nom, as: :text, sortable: true, readonly: true
  field :emplacement, as: :text, sortable: true, hide_on: [:index], readonly: true
  field :nom_dossier, as: :text, sortable: true, hide_on: [:index], readonly: true
  field :last_recolement_at, as: :datetime, sortable: true, hide_on: [:index], readonly: true
  field :image_urls, as: :text, sortable: true, hide_on: [:index], readonly: true
  field :created_at, as: :datetime, sortable: true
  # field :ref_memoire, as: :text, sortable: true,
  # field :commune_nom, as: :text, sortable: true,
  # field :commune_code_insee, as: :text, sortable: true
  # field :updated_at, as: :text, sortable: true

  field :recensements, as: :has_many
end
