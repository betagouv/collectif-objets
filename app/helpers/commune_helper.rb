# frozen_string_literal: true

module CommuneHelper
  def commune_status_badge(commune)
    color = { inactive: "", started: :info, completed: :success }
      .with_indifferent_access[commune.status]
    text = I18n.t("activerecord.attributes.commune.statuses.#{commune.status}")
    content_tag("p", text, class: "fr-badge fr-badge--sm fr-badge--#{color}")
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
    [
      ["Tout sélectionner", ""],
      [Commune::STATUT_GLOBAL_EXAMINÉ, Commune::ORDRE_EXAMINÉ],
      [Commune::STATUT_GLOBAL_EN_COURS_D_EXAMEN, Commune::ORDRE_EN_COURS_D_EXAMEN],
      [Commune::STATUT_GLOBAL_EXAMEN_OPTIONNEL, Commune::ORDRE_EXAMEN_OPTIONNEL],
      [Commune::STATUT_GLOBAL_A_EXAMINER, Commune::ORDRE_A_EXAMINER],
      [Commune::STATUT_GLOBAL_EN_COURS_DE_RECENSEMENT, Commune::ORDRE_EN_COURS_DE_RECENSEMENT],
      [Commune::STATUT_GLOBAL_NON_RECENSÉ, Commune::ORDRE_NON_RECENSÉ]
    ]
  end

  def commune_statut_global_badge(commune, **options)
    colors = ["", "", "success", "blue-ecume", "blue-ecume", "success"]
    content_tag(
      "p",
      commune.statut_global_texte,
      class: class_names(options[:class], "fr-badge", "fr-badge--#{colors[commune.statut_global]}",
                         { "fr-badge--sm": options[:small] })
    )
  end

  def commune_name_with_objets_rouges_count(commune)
    data = [commune.nom]
    if commune.en_peril_count.positive?
      data << Objet.human_attribute_name(:en_peril_count, count: commune.en_peril_count)
    end
    if commune.disparus_count.positive?
      data << Objet.human_attribute_name(:disparus_count, count: commune.disparus_count)
    end
    data.join(", ")
  end
end
