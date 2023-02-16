# frozen_string_literal: true

module DossierHelper
  def dossier_status_badge(dossier)
    color = {
      construction: "new",
      submitted: "info",
      rejected: "warning",
      accepted: "success"
    }[dossier.status.to_sym]
    content_tag(
      "p",
      t("dossier.status_badge.#{dossier.status}"),
      class: "fr-badge fr-badge--sm fr-badge--#{color}"
    )
  end
  # rubocop:enable Metrics/MethodLength

  def dossier_visit_badge(dossier)
    case dossier.visit
    when "souhaitable"
      content_tag(:span, "Visite souhaitable", class: "fr-badge fr-badge--info")
    when "prioritaire"
      content_tag(:span, "Visite prioritaire", class: "fr-badge fr-badge--warning")
    end
  end
end
