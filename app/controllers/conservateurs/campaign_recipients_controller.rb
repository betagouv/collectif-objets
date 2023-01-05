# frozen_string_literal: true

module Conservateurs
  class CampaignRecipientsController < BaseController
    include CampaignRecipientsControllerConcern

    private

    def routes_prefix = :conservateurs

    def authorize_recipient
      authorize @recipient
    end
  end
end
