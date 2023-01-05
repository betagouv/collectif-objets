# frozen_string_literal: true

module Conservateurs
  class CampaignPolicy < BasePolicy
    alias campaign record

    def show?
      conservateur.departements.include?(campaign.departement)
    end
    alias create? show?
    alias update? show?
    alias edit_recipients? show?
    alias update_recipients? show?
    alias update_status? show?
    alias mail_previews? show?

    def destroy?
      campaign.draft? &&
        conservateur.departements.include?(campaign.departement)
    end

    class Scope < Scope
      def resolve
        scope.where(departement: conservateur.departements)
      end
    end
  end
end
