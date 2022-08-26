# frozen_string_literal: true

class CampaignEmailsStatsComponentPreview < ViewComponent::Preview
  def default
    stats_group = {
      count: 120,
      pending: { count_exclusive: 5 },
      sent: { count_exclusive: 115 },
      delivered: { count_exclusive: 110 },
      opened: { count_exclusive: 50 },
      clicked: { count_exclusive: 30 },
      error: { count_exclusive: 3 }
    }
    render(Campaigns::EmailsStatsComponent.new(stats_group))
  end
end
