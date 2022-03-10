class RecensementResource < Avo::BaseResource
  ETAT_OPTIONS_BADGE = {
    success: Recensement::ETAT_BON,
    info: Recensement::ETAT_CORRECT,
    warning: Recensement::ETAT_MAUVAIS,
    danger: Recensement::ETAT_PERIL,
  }.freeze
  ETAT_OPTIONS_SELECT = [
    Recensement::ETAT_BON,
    Recensement::ETAT_CORRECT,
    Recensement::ETAT_MAUVAIS,
    Recensement::ETAT_PERIL,
  ].map { [_1, _1] }.to_h


  self.title = :id
  self.includes = []
  # self.search_query = ->(params:) do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id

  field :objet, as: :belongs_to

  field(
    :localisation,
    as: :select,
    hide_on: [:show, :index],
    options: [
      Recensement::LOCALISATION_EDIFICE_INITIAL,
      Recensement::LOCALISATION_AUTRE_EDIFICE,
      Recensement::LOCALISATION_ABSENT
    ].map { [_1, _1] }.to_h,
    placeholder: "Localisation"
  )
  field :localisation, as: :badge, options: {success: "edifice_initial", info: "autre_edifice", danger: "absent"}, sortable: true
  field :recensable, as: :boolean
  field :edifice_nom, as: :text

  field :etat_sanitaire_edifice, as: :badge, options: ETAT_OPTIONS_BADGE, sortable: true
  field :etat_sanitaire_edifice, as: :select, hide_on: [:show, :index], options: ETAT_OPTIONS_SELECT

  field :etat_sanitaire, as: :badge, options: ETAT_OPTIONS_BADGE, sortable: true
  field :etat_sanitaire, as: :select, hide_on: [:show, :index], options: ETAT_OPTIONS_SELECT

  field :securisation, as: :badge, options: {
    success: Recensement::SECURISATION_CORRECTE,
    danger: Recensement::SECURISATION_MAUVAISE,
  }, sortable: true
  field :securisation, as: :select, hide_on: [:show, :index], options: [
    Recensement::SECURISATION_CORRECTE,
    Recensement::SECURISATION_MAUVAISE,
  ].map { [_1, _1] }.to_h

  field :notes, as: :text, format_using: -> (t) { t.present? ? t[0..30] : t }
  field :photos, as: :files
end
