# frozen_string_literal: true

module Conservateurs
  class DossierPolicy < BasePolicy
    alias dossier record

    def show?
      conservateur.departements.include?(dossier.departement)
    end

    class Scope < Scope
      def resolve
        scope.joins(:commune).where(communes: { departement: conservateur.departements })
      end
    end
  end
end
