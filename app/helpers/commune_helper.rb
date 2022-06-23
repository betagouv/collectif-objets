# frozen_string_literal: true

# rubocop:disable Rails/OutputSafety
module CommuneHelper
  def commune_status_badge(commune)
    color = {
      Commune::STATE_INACTIVE => :new,
      Commune::STATE_ENROLLED => :info,
      Commune::STATE_STARTED => :info,
      Commune::STATE_COMPLETED => :success
    }[commune.status]
    text = I18n.t("activerecord.attributes.commune.statuses.#{commune.status}")
    "<p class=\"fr-badge fr-badge--sm fr-badge--#{color}\">#{text}</p>".html_safe
  end
end
# rubocop:enable Rails/OutputSafety
