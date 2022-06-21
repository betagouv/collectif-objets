# frozen_string_literal: true

module DossierHelper
  # rubocop:disable Metrics/MethodLength
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
end
