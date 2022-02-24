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
  field :ref_pop, as: :text, sortable: true, link_to_resource: true
  field :nom_courant, as: :text, sortable: true
  field :first_image_url, as: :external_image
  field :nom, as: :text, hide_on: [:index]
  field :commune, as: :belongs_to, searchable: true
  field :categorie, as: :text, sortable: true
  field :crafted_at, as: :text, sortable: true
  field :departement, as: :text, sortable: true, hide_on: [:index]
  field :recolement_status, as: :text, sortable: true
  field :edifice_nom, as: :text, sortable: true
  field :emplacement, as: :text, sortable: true, hide_on: [:index]
  field :nom_dossier, as: :text, sortable: true, hide_on: [:index]
  field :last_recolement_at, as: :text, sortable: true, hide_on: [:index]
  field :image_urls, as: :text, sortable: true, hide_on: [:index]
  field :created_at, as: :text, sortable: true
  # field :ref_memoire, as: :text, sortable: true,
  # field :commune_nom, as: :text, sortable: true,
  # field :commune_code_insee, as: :text, sortable: true
  # field :updated_at, as: :text, sortable: true
end
