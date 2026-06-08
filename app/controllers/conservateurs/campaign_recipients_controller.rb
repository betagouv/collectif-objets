# frozen_string_literal: true

module Conservateurs
  class CampaignRecipientsController < BaseController
    include CampaignRecipientsControllerConcern

    private

    def routes_prefix = :conservateurs

    def authorize_recipient!
      authorize @recipient
    end

    def active_nav_links = ["Mes départements", @commune.departement.to_s]
  end
end
