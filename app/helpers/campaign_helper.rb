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
    [
      { label: "Inactive", backgroundColor: "rgba(254, 238, 113, 1)", data: [statuses_stats.fetch("inactive", 0)] },
      { label: "Recensement démarré", backgroundColor: "rgba(94, 100, 255, 1)",
        data: [statuses_stats.fetch("started", 0)] },
      { label: "Recensement terminé", backgroundColor: "rgba(30, 100, 30, 1)",
        data: [statuses_stats.fetch("completed", 0)] }
    ]
  end

  def campaign_objets_statuses_line_chart_datasets(objets_stats)
    [
      { label: "Pas encore recensé", backgroundColor: "rgba(254, 238, 113, 1)",
        data: [objets_stats.fetch("not_recensed", 0)] },
      { label: "Recensé", backgroundColor: "rgba(94, 100, 255, 1)", data: [objets_stats.fetch("recensed", 0)] }
    ]
  end
end
