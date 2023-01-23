# frozen_string_literal: true

module Conservateurs
  class MessagePolicy < BasePolicy
    alias message record

    def show?
      conservateur.departements.include?(message.commune.departement)
    end

    def create?
      conservateur.departements.include?(message.commune.departement) && !impersonating?
    end

    class Scope < Scope
      def resolve
        scope.joins(:commune).where(communes: { departement: conservateur.departements })
      end
    end
  end
end
