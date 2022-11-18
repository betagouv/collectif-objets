# frozen_string_literal: true

module Conservateurs
  class DepartementPolicy < ApplicationPolicy
    alias conservateur user
    alias departement record

    def show?
      conservateur.departements.include?(departement)
    end

    class Scope < Scope
      alias conservateur user
      def resolve
        scope.where(code: conservateur.departement_ids)
      end
    end
  end
end
