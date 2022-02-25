class UserResource < Avo::BaseResource
  self.title = :email
  self.includes = []
  self.search_query = ->(params:) do
    scope.ransack(
      id_eq: params[:q],
      email_cont: params[:q],
      m: "or"
    ).result(distinct: false)
  end

  field :id, as: :id, link_to_resource: true
  field :email, as: :text, sortable: true, link_to_resource: true
  field :magic_token, as: :text, sortable: true, format_using: -> (t) { link_to("#{t} ↗️" || "", "https://collectif-objets.beta.gouv.fr/magic-authentication?magic-token=#{t}", target: "_blank") }
  field :last_sign_in_at, as: :datetime, sortable: true
  field :reset_password_sent_at, as: :text, hide_on: [:index]
  field :login_token, as: :text, hide_on: [:index], sortable: true
  field :login_token_valid_until, as: :datetime, hide_on: [:index], sortable: true
  field :created_at, as: :datetime, sortable: true
  field :updated_at, as: :datetime, hide_on: [:index]
  field :commune, as: :belongs_to
  field :encrypted_password, as: :text, hide_on: [:index]
end
