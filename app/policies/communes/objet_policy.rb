# frozen_string_literal: true

module Communes
  class ObjetPolicy < ApplicationPolicy
    def show?
      user.commune == record.commune
    end

    class Scope < Scope
      def resolve
        scope.where(commune: user.commune)
      end
    end
  end
end
