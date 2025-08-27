# frozen_string_literal: true

module Communes
  class RecenseurPolicy < BasePolicy
    def show?
      record.accesses.exists?(commune: user.commune)
    end

    class Scope < Scope
      def resolve
        scope.joins(:accesses).where(recenseur_accesses: { commune: user.commune })
      end
    end
  end
end
