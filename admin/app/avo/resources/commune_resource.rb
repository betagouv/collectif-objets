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
  # field :email, sortable: true, as: :text
  field :phone_number, sortable: true, as: :text
  field :population, sortable: true, as: :number
  field :users, as: :has_many
  field :objets, as: :has_many
end
