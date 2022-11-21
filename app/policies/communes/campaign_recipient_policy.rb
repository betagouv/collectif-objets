# frozen_string_literal: true

module Communes
  class CampaignRecipientPolicy < ApplicationPolicy
    alias campaign_recipient record

    def update?
      user_commune?
    end

    private

    def user_commune?
      user.commune == campaign_recipient.commune
    end
  end
end
