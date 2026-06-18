# frozen_string_literal: true

module Recenseurs
  class ObjetPolicy < BasePolicy
    def show?
      recenseur.communes.include?(record.commune)
    end

    class Scope < Scope
      def resolve
        scope.where(commune: recenseur.communes)
      end
    end
  end
end
