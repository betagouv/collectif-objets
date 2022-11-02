# frozen_string_literal: true

module Conservateurs
  class RecensementPolicy < BasePolicy
    alias recensement record

    def create?
      conservateur.departements.include?(recensement.departement)
    end
    alias update? create?

    # class Scope < Scope
    #   def resolve
    #     scope.where(departement: conservateur.departements)
    #   end
    # end
  end
end
