# frozen_string_literal: true

module DossierHelper
  def dossier_status_badge(dossier, small: false)
    color = {
      construction: "new",
      submitted: "info",
      accepted: "success"
    }[dossier.status.to_sym]
    content_tag(
      "p",
      t("dossier.status_badge.#{dossier.status}"),
      class: "fr-badge fr-badge--#{color} #{small ? 'fr-badge--sm' : ''}"
    )
  end
  # rubocop:enable Metrics/MethodLength

  def dossier_visit_badge(dossier)
    case dossier.visit
    when "souhaitable"
      dsfr_badge(status: :info, classes: ["fr-badge--no-icon"]) { "Déplacement souhaitable" }
    when "prioritaire"
      dsfr_badge(status: :warning, classes: ["fr-badge--no-icon"]) { "Déplacement prioritaire" }
    end
  end

  def dossier_visit_tag(dossier)
    titre = "Déplacement #{dossier.visit == 'prioritaire' ? 'prioritaire' : 'souhaitable'}"
    dsfr_tag(title: titre)
  end
end
