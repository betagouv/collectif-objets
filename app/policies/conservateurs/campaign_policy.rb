# frozen_string_literal: true

module Conservateurs
  class CampaignPolicy < BasePolicy
    alias campaign record

    def show?
      conservateur.departements.include?(campaign.departement)
    end

    class Scope < Scope
      def resolve
        scope.where(departement: conservateur.departements)
      end
    end
  end
end
