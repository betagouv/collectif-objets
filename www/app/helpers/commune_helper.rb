# frozen_string_literal: true

# rubocop:disable Rails/OutputSafety
module CommuneHelper
  def commune_status_badge(commune)
    color = {
      Commune::STATUS_INACTIVE => :new,
      Commune::STATUS_ENROLLED => :info,
      Commune::STATUS_STARTED => :info,
      Commune::STATUS_COMPLETED => :success
    }[commune.status]
    text = I18n.t("activerecord.attributes.commune.statuses.#{commune.status}")
    "<p class=\"fr-badge fr-badge--sm fr-badge--#{color}\">#{text}</p>".html_safe
  end
end
# rubocop:enable Rails/OutputSafety
