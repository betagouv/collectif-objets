# frozen_string_literal: true

module Recenseurs
  class CommunePolicy < BasePolicy
    alias commune record

    def show?
      recenseur.granted_accesses.with_edifices.exists?(commune:)
    end
    alias historique? show?

    def dossier?
      recenseur.access_for(commune)&.all_edifices?
    end

    class Scope < Scope
      def resolve
        scope.where(id: recenseur.granted_accesses.with_edifices.select(:commune_id))
      end
    end
  end
end
