# frozen_string_literal: true

module Conservateurs
  class CommunePolicy < BasePolicy
    alias commune record

    def historique?
      show?
    end

    def show?
      conservateur.departements.include?(commune.departement)
    end

    class Scope < Scope
      def resolve
        scope.where(departement: conservateur.departements)
      end
    end
  end
end
