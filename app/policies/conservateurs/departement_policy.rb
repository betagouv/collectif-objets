# frozen_string_literal: true

module Conservateurs
  class DepartementPolicy < BasePolicy
    alias departement record

    def show?
      conservateur.departements.include?(departement)
    end

    class Scope < Scope
      def resolve
        scope.where(code: conservateur.departement_ids)
      end
    end
  end
end
