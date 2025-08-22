# frozen_string_literal: true

module Conservateurs
  class RecenseurPolicy < BasePolicy
    alias recenseur record

    def new? = true
    def create? = true

    def show?
      return recenseur.accesses.none? || recenseur.departements.intersect?(conservateur.departements)
    end
    alias edit? show?
    alias update? show?
    alias destroy? show?

    class Scope < Scope
      def resolve
        # Recenseurs ayant accès à une commune du département ou plus
        # ou nouvellement créé (aucun accès)
        scope.joins(:departements).where(departements: user.departements)
             .or(scope.where(id: scope.without_access.ids))
      end
    end
  end
end
