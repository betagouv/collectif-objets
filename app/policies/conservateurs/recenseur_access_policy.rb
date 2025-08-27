# frozen_string_literal: true

module Conservateurs
  class RecenseurAccessPolicy < BasePolicy
    alias recenseur_access record

    def create?
      conservateur.departements.include? recenseur_access.departement
    end
    alias update?  create?
    alias destroy? create?
  end
end
