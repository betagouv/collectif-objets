# frozen_string_literal: true

module Conservateurs
  class CampaignRecipientPolicy < BasePolicy
    alias recipient record

    def show?
      conservateur.departements.include? recipient.departement
    end
    alias mail_preview? show?
    alias update? show?
  end
end
