# frozen_string_literal: true

module Co
  module Conservateurs
    class CampaignSearch
      attr_reader :status, :departement_code

      def initialize(status: nil, departement_code: nil)
        @status = status.presence
        @departement_code = departement_code.presence
      end

      def resolve
        campaigns = Campaign.all
        campaigns = campaigns.where(status:) if status.present?
        campaigns = campaigns.where(departement_code:) if departement_code.present?
        campaigns
      end

      def filters?
        status || departement_code
      end
    end
  end
end
