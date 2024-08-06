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
    nb_started = statuses_stats.fetch("construction", 0)
    nb_submitted = statuses_stats.fetch("submitted", 0)
    nb_accepted = statuses_stats.fetch("accepted", 0)
    nb_inactive = statuses_stats.fetch("total", 0) - (nb_started + nb_submitted + nb_accepted)
    [
      { label: "Inactive", data: [nb_inactive], backgroundColor: "rgb(254, 247, 218)" },
      { label: "En cours de recensement", data: [nb_started], backgroundColor: "rgb(252, 198, 58)" },
      { label: "Recensement terminé", data: [nb_submitted], backgroundColor: "rgb(192, 140, 101)" },
      { label: "Recensement examiné", data: [nb_accepted], backgroundColor: "rgb(149, 226, 87)" }
    ]
  end

  def campaign_objets_statuses_line_chart_datasets(objets_stats)
    nb_recensés = objets_stats.fetch("recensed", 0)
    nb_non_recensés = objets_stats.fetch("not_recensed", 0)
    [
      { label: "Pas encore recensé", data: [nb_non_recensés], backgroundColor: "rgb(254, 247, 218)" },
      { label: "Recensé", data: [nb_recensés], backgroundColor: "rgb(149, 226, 87)" }
    ]
  end
end
