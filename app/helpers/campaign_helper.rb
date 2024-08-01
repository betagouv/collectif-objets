# frozen_string_literal: true

module CampaignHelper
  def campaign_status_badge(campaign)
    color = {
      "draft" => :warning,
      "planned" => :new,
      "ongoing" => :info,
      "finished" => :success
    }[campaign.status]
    text = I18n.t("activerecord.attributes.campaign.statuses.#{campaign.status}")
    tag.span text, class: "fr-badge fr-badge--sm fr-badge--#{color}"
  end

  def campaigns_statuses_options
    Campaign::STATUSES.map { [t("activerecord.attributes.campaign.statuses.#{_1}"), _1] }
  end

  def campaign_title(campaign)
    "#{campaign.departement.nom} #{campaign.date_lancement.strftime('%m/%Y')}"
  end

  def campaign_communes_statuses_line_chart_datasets(statuses_stats)
    started = statuses_stats.fetch("construction", 0)
    submitted = statuses_stats.fetch("submitted", 0)
    accepted = statuses_stats.fetch("accepted", 0)
    inactive = statuses_stats.fetch("total", 0) - (started + submitted + accepted)
    [
      { label: "Inactive", data: [inactive], backgroundColor: "rgb(254, 247, 218)" },
      { label: "En cours de recensement", data: [started], backgroundColor: "rgb(252, 198, 58)" },
      { label: "Recensement terminé", data: [submitted], backgroundColor: "rgb(192, 140, 101)" },
      { label: "Recensement examiné", data: [accepted], backgroundColor: "rgb(149, 226, 87)" }
    ]
  end

  def campaign_objets_statuses_line_chart_datasets(objets_stats)
    recensés = objets_stats.fetch("recensed", 0)
    non_recensés = objets_stats.fetch("not_recensed", 0)
    [
      { label: "Pas encore recensé", data: [non_recensés], backgroundColor: "rgb(254, 247, 218)" },
      { label: "Recensé", data: [recensés], backgroundColor: "rgb(149, 226, 87)" }
    ]
  end
end
