# frozen_string_literal: true

module Conservateurs
  class AnalysePolicy < BasePolicy
    alias analyse record

    def update?
      conservateur.departements.include?(analyse.departement) &&
        analyse.commune.completed?
    end

    class Scope < Scope
      def resolve
        # scope.where(departement: conservateur.departements)
      end
    end
  end
end
