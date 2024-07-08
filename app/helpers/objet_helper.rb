# frozen_string_literal: true

module ObjetHelper
  def edifice_nom(nom)
    return nom.upcase_first if nom.present?

    content_tag(:i, "Édifice non renseigné")
  end

  def palissy_url(objet)
    palissy_url_ref objet.palissy_REF
  end

  def palissy_url_ref(ref)
    "https://www.pop.culture.gouv.fr/notice/palissy/#{ref}"
  end

  def link_to_palissy(objet, **, &)
    link_to(palissy_url(objet), target: "_blank", rel: "noopener", **, &)
  end

  def objet_recensement_badge_color_and_text(objet)
    recensement = objet.recensement
    dossier = recensement&.dossier
    return nil if dossier&.accepted?

    {
      nil => ["", "Pas encore recensé"],
      "completed" => %w[success Recensé],
      "draft" => ["info", "Recensement à compléter"]
    }[recensement&.status]
  end

  def objet_recensement_badge(objet)
    color, text = objet_recensement_badge_color_and_text(objet)
    return nil unless color && text

    content_tag(:span, class: "fr-badge fr-badge--md fr-badge--#{color}") { text }
  end
end
