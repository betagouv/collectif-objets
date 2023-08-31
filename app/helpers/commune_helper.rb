# frozen_string_literal: true

# rubocop:disable Rails/OutputSafety
module CommuneHelper
  def commune_status_badge(commune)
    color = { inactive: "", started: :info, completed: :success }
      .with_indifferent_access[commune.status]
    text = I18n.t("activerecord.attributes.commune.statuses.#{commune.status}")
    "<p class=\"fr-badge fr-badge--sm fr-badge--#{color}\">#{text}</p>".html_safe
  end

  def commune_messagerie_title(commune)
    if commune.messages.count.positive?
      "Messagerie (#{commune.messages.count})"
    else
      "Messagerie"
    end
  end

  def commune_recenser_objets_text(commune)
    text = commune.objets.count > 1 ? "Recenser les objets" : "Recenser l’objet"
    text + " de #{commune.nom}"
  end

  def communes_statuses_options_for_select
    [["Veuillez sélectionner une option", ""],
     [Commune::STATUT_GLOBAL_NON_RECENSÉ, Commune::ORDRE_NON_RECENSÉ],
     [Commune::STATUT_GLOBAL_EN_COURS_DE_RECENSEMENT, Commune::ORDRE_EN_COURS_DE_RECENSEMENT],
     [Commune::STATUT_GLOBAL_NON_ANALYSÉ, Commune::ORDRE_NON_ANALYSÉ],
     [Commune::STATUT_GLOBAL_EN_COURS_D_ANALYSE, Commune::ORDRE_EN_COURS_D_ANALYSE],
     [Commune::STATUT_GLOBAL_ANALYSÉ, Commune::ORDRE_ANALYSÉ]]
  end
end
# rubocop:enable Rails/OutputSafety
