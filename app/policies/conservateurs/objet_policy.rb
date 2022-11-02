# frozen_string_literal: true

module Conservateurs
  class ObjetPolicy < BasePolicy
    alias objet record

    def show?
      conservateur.departements.include?(objet.departement)
    end
    alias update? create?

    # class Scope < Scope
    #   def resolve
    #     scope.where(departement: conservateur.departements)
    #   end
    # end
  end
end
