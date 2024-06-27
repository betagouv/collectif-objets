# frozen_string_literal: true

# rubocop:disable Rails/OutputSafety
module CampaignHelper
  RECIPIENT_STATUSES_BADGES_DATA = {
    completed: %w[checkbox-circle green],
    started: %w[checkbox-circle blue],
    step_fin: %w[close red]
  }.freeze

  def campaign_status_badge(campaign)
    color = {
      "draft" => :warning,
      "planned" => :new,
      "ongoing" => :info,
      "finished" => :success
    }[campaign.status]
    text = I18n.t("activerecord.attributes.campaign.statuses.#{campaign.status}")
    "<span class=\"fr-badge fr-badge--sm fr-badge--#{color}\">#{text}</span>".html_safe
  end

  def campaign_recipient_status_badge(recipient)
    return nil if recipient.status.blank?

    content_tag(
      :span,
      campaign_recipient_status_icon_and_text(recipient),
      title: I18n.t("activerecord.attributes.campaign_recipient.statuses.#{recipient.status}")
    )
  end

  def campaign_email_badges(email)
    [
      email.sent? ? %w[info Envoyé] : nil,
      email.delivered? ? %w[success Reçu] : nil,
      email.clicked? ? %w[success Cliqué] : nil,
      email.error? ? %w[error Erreur] : nil
    ].compact.map do |color, text|
      content_tag(:span, text, class: "fr-badge fr-badge--sm fr-badge--#{color}")
    end
  end

  def campaign_recipient_status_icon_and_text(recipient)
    data = campaign_recipient_status_badge_data(recipient)
    icon = content_tag(
      :span, "",
      class: "fr-icon-#{data[:icon_name]}-line co-text--#{data[:color]} fr-fi--sm",
      "aria-hidden": "true"
    )
    icon + content_tag(:span, data[:text] || "")
  end

  def campaign_recipient_status_badge_data(recipient)
    icon_name, color = RECIPIENT_STATUSES_BADGES_DATA[recipient.status.to_sym]
    return { icon_name:, color: } if icon_name && color

    number = %i[step_lancement step_relance1 step_relance2 step_relance3].index(recipient.status.to_sym)
    return unless number

    { icon_name: "mail", color: email_color(recipient.email_for_current_step), text: number.to_s }
  end

  def email_color(email)
    return if email.blank?

    return "red" if email.error?

    return "green" if email.delivered?

    "blue"
  end

  def campaign_recipient_opt_out_badge(recipient)
    return unless recipient.opt_out?

    content_tag(:span, "⛔️", title: "Ne souhaite plus recevoir d'emails")
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
# rubocop:enable Rails/OutputSafety
