# frozen_string_literal: true

module Conservateurs
  class RecenseurPolicy < BasePolicy
    alias recenseur record

    def new? = true
    def create? = true

    def show?
      return true if recenseur.accesses.none?

      recenseur.accesses.joins(:commune)
                        .where(communes: { departement_code: conservateur.departements.pluck(:code) })
                        .exists?
    end
    alias edit? show?
    alias update? show?
    alias destroy? show?

    class Scope < Scope
      def resolve
        # Recenseurs sans aucuns accès (pour permettre la création en 2 écrans)
        # OU ayant accès (peu importe son état) à une commune du département
        with_access_to_dept = scope.joins(accesses: :commune)
                                   .where(communes: { departement_code: conservateur.departements.pluck(:code) })

        without_access = scope.without_access

        scope.where(id: without_access.ids)
             .or(scope.where(id: with_access_to_dept.ids))
             .distinct
      end
    end
  end
end
