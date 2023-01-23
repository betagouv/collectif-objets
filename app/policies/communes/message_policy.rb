# frozen_string_literal: true

module Communes
  class MessagePolicy < BasePolicy
    alias message record

    def show
      message.commune == user.commune
    end

    def create?
      message.commune == user.commune && !impersonating?
    end

    class Scope < Scope
      def resolve
        scope.where(commune: user.commune)
      end
    end
  end
end
