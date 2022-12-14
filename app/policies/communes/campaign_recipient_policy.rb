# frozen_string_literal: true

module Communes
  class CampaignRecipientPolicy < BasePolicy
    alias campaign_recipient record

    def update?
      user_commune? && !impersonating?
    end

    private

    def user_commune?
      user.commune == campaign_recipient.commune
    end
  end
end
