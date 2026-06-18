# frozen_string_literal: true

module Recenseurs
  class BasePolicy < ApplicationPolicy
    alias recenseur user

    def impersonating?
      recenseur.impersonating
    end

    class Scope < Scope
      alias recenseur user
    end
  end
end
