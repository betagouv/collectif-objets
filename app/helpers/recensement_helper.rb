# frozen_string_literal: true

module RecensementHelper
  Option = Struct.new :value, :label, :badge_color

  def etat_badge_color(etat)
    {
      Recensement::ETAT_BON => "success",
      Recensement::ETAT_MOYEN => "info",
      Recensement::ETAT_MAUVAIS => "new",
      Recensement::ETAT_PERIL => "warning"
    }[etat]
  end

  def etat_sanitaire_options
    Recensement::ETATS.map do |etat|
      Option.new(
        etat,
        t("recensement.etat_sanitaire_choices.#{etat}"),
        etat_badge_color(etat)
      )
    end
  end

  def etat_sanitaire_options_for_select
    etat_sanitaire_options.map { [_1.label, _1.value] }
  end

  def etat_sanitaire_badge(value, **html_opts)
    badge(etat_badge_color(value), **html_opts) do
      t("recensement.etat_sanitaire_choices.#{value}")
    end
  end

  alias analyse_etat_sanitaire_badge etat_sanitaire_badge

  def securisation_options
    [
      Option.new(
        Recensement::SECURISATION_MAUVAISE,
        t("recensement.securisation_choices.en_danger"),
        "warning"
      ),
      Option.new(
        Recensement::SECURISATION_CORRECTE,
        t("recensement.securisation_choices.en_securite"),
        "success"
      )
    ]
  end

  def securisation_badge(value, **html_opts)
    opt = securisation_options.find { _1.value == value }
    badge(opt.badge_color, **html_opts) { opt.label }
  end
  alias securisation_edifice_badge securisation_badge
  alias analyse_securisation_badge securisation_badge

  def securisation_options_for_select
    securisation_options.map { [_1.label, _1.value] }
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

  def analyse_attribute_component(recensement:, form_builder:, recensement_presenter:, attribute_name:)
    original_attribute_name = attribute_name
    if recensement.analysable?
      Conservateurs::AnalyseOverrideEditableComponent.new \
        form_builder:, recensement_presenter:, original_attribute_name:
    else
      Conservateurs::AnalyseOverrideComponent.new \
        recensement:, recensement_presenter:, original_attribute_name:
    end
  end

  def edit_recensement_step_link(recensement, step, **)
    button_to(
      "Modifier",
      edit_commune_objet_recensement_path(recensement.commune, recensement.objet, recensement),
      params: { step: },
      class: "fr-btn fr-btn--sm fr-btn--icon-left fr-icon-edit-line fr-btn--tertiary fr-btn--tertiary-no-outline",
      data: { turbo_action: "advance" },
      form_class: "co-display--inline co-edit-button",
      method: :get,
      **
    )
  end

  def recensement_nom_edifice(recensement)
    return recensement.objet.palissy_EDIF if recensement.edifice_initial?
    return recensement.edifice_nom if recensement.deplacement_definitif?

    nil
  end

  # TODO : À supprimer au profit du RecensementPresenter#nom_commune_localisation_objet
  def nom_commune_localisation_objet(recensement)
    recensement.nom_commune_localisation_objet.presence || "avec le code INSEE #{recensement.autre_commune_code_insee}"
  end

  def deleted_recensement_title(recensement)
    "Recensement supprimé de l’objet #{recensement.deleted_objet_snapshot['palissy_REF']}"
  end
end
