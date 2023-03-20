# frozen_string_literal: true

module Admin
  class CampaignRecipientsController < BaseController
    include CampaignRecipientsControllerConcern

    private

    def routes_prefix = :admin

    def authorize_recipient = true
    def active_nav_links = %w[Campagnes]
  end
end
