# frozen_string_literal: true

module Communes
  class MessagePolicy < BasePolicy
    alias message record

    def create?
      message.commune == user.commune
    end
    alias show? create?

    class Scope < Scope
      def resolve
        scope.where(commune: user.commune)
      end
    end
  end
end
