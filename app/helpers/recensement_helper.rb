# frozen_string_literal: true

module RecensementHelper
  def etat_badge_color(etat)
    {
      Recensement::ETAT_BON => "success",
      Recensement::ETAT_MOYEN => "info",
      Recensement::ETAT_MAUVAIS => "new",
      Recensement::ETAT_PERIL => "warning"
    }[etat]
  end

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

  def edit_recensement_step_link(recensement, step, **kwargs)
    button_to \
      "",
      edit_commune_objet_recensement_path(recensement.commune, recensement.objet, recensement),
      params: { step: },
      class: "fr-btn fr-btn--sm fr-icon-edit-line fr-btn--tertiary fr-btn--tertiary-no-outline",
      data: { turbo_action: "advance" },
      form_class: "co-display--inline co-edit-button",
      method: :get,
      **kwargs
  end

  def recensement_nom_edifice(recensement)
    return recensement.objet.palissy_EDIF if recensement.edifice_initial?
    return recensement.edifice_nom if recensement.autre_edifice?

    nil
  end
end
