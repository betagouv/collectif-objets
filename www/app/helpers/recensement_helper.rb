# frozen_string_literal: true

module RecensementHelper
  Option = Struct.new :value, :label

  # rubocop:disable Metrics/MethodLength
  def localisation_options(recensement)
    [
      Option.new(
        Recensement::LOCALISATION_EDIFICE_INITIAL,
        "L'objet est bien présent dans l'édifice #{recensement.objet.edifice_nom}"
      ),
      Option.new(
        Recensement::LOCALISATION_AUTRE_EDIFICE,
        "L'objet est présent dans un autre édifice"
      ),
      Option.new(
        Recensement::LOCALISATION_ABSENT,
        "L’objet est introuvable, ou bien vous savez qu'il a disparu"
      )
    ]
  end

  def etat_sanitaire_options
    [
      Option.new(
        Recensement::ETAT_BON,
        "Bon"
      ),
      Option.new(
        Recensement::ETAT_CORRECT,
        "Moyen"
      ),
      Option.new(
        Recensement::ETAT_MAUVAIS,
        "Mauvais"
      ),
      Option.new(
        Recensement::ETAT_PERIL,
        "En péril"
      )
    ]
  end

  def securisation_options
    [
      Option.new(
        Recensement::SECURISATION_CORRECTE,
        "Oui, il est difficile de le voler"
      ),
      Option.new(
        Recensement::SECURISATION_MAUVAISE,
        "Non, il peut être emporté facilement"
      )
    ]
  end

  def recensable_options
    [
      Option.new(
        "true",
        "Oui"
      ),
      Option.new(
        "false",
        "Non"
      )
    ]
  end
  # rubocop:enable Metrics/MethodLength
end
