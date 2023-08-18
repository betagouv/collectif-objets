# frozen_string_literal: true

module DossierHelper
  def dossier_status_badge(dossier, small: false)
    color = ""
    if dossier.nil?
      libellé = "Non recensé"
    else
      libellé = t("dossier.status_badge.#{dossier.status}")
      if dossier.accepted?
        color = "success"
      elsif dossier.submitted?
        color = "blue-ecume"
      end
    end
    content_tag("p", libellé, class: "fr-badge #{small ? 'fr-badge--sm' : ''} fr-badge--#{color}")
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
