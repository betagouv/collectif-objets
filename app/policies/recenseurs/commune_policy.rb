# frozen_string_literal: true

module Recenseurs
  class CommunePolicy < BasePolicy
    alias commune record

    def show?
      recenseur.communes.include?(commune)
    end
    alias historique? show?

    class Scope < Scope
      def resolve
        scope.where(id: recenseur.commune_ids)
      end
    end
  end
end
