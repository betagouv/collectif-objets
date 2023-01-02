# frozen_string_literal: true

module Campaigns
  class EmailsStatsComponent < ViewComponent::Base
    include ApplicationHelper

    KEYS = %i[error pending sent delivered clicked].freeze

    COLORS = {
      error: "red",
      pending: "yellow",
      sent: "#1c5b15",
      delivered: "#28841e",
      clicked: "#47e535"
    }.freeze

    def initialize(campaign_email_stats_group)
      @stats = campaign_email_stats_group
      super
    end

    def values
      KEYS.map { @stats[_1][:count_exclusive] }
    end

    def labels
      KEYS.map { I18n.t("campaigns.email_stats_labels.#{_1}") }
    end

    def colors
      KEYS.map { COLORS[_1] }
    end
  end
end
